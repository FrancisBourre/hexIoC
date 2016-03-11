package hex.ioc.parser.xml;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.CompileTimeApplicationAssembler;
import hex.ioc.core.CompileTimeCoreFactory;


import hex.ioc.core.ContextNameList;
import hex.ioc.core.ContextTypeList;
import hex.ioc.error.ParsingException;
import hex.ioc.vo.DomainListenerVOArguments;

/**
 * ...
 * @author Francis Bourre
 */
class XMLFileReader
{
	static var _includeMatcher 	: EReg = ~/<include.*?file=("|')([^"']+)\1.*?(?:(?:\/>)|(?:>[\W\w\t\r\n]*?<\/import *>))/g;
	static var _headerMatcher 	: EReg = ~/(?:<\?xml[^>]+>\s*)<([a-zA-Z0-9-_:]+)[^>]*>([\s\S]*)<\/\1\s*>/;
	
	static var _assembler 		: CompileTimeApplicationAssembler;
	static var _compiledClass	: Array<String>;
	static var _primType		: Array<String> = [	ContextTypeList.STRING, 
													ContextTypeList.INT, 
													ContextTypeList.UINT, 
													ContextTypeList.FLOAT, 
													ContextTypeList.BOOLEAN, 
													ContextTypeList.NULL, 
													ContextTypeList.OBJECT, 
													ContextTypeList.XML, 
													ContextTypeList.CLASS, 
													ContextTypeList.FUNCTION, 
													ContextTypeList.ARRAY
												];
	
	#if macro
	static function checkForInclude( data : String )
	{
		if ( XMLFileReader._includeMatcher.match( data ) )
		{
			var f = function( eReg: EReg ) : String 
			{
				
				var fileName : String = XMLFileReader._includeMatcher.matched( 2 );
				var data : String = XMLFileReader.readFile( fileName );
				return XMLFileReader.cleanHeader( data );
			}
			
			data = XMLFileReader._includeMatcher.map( data, f );
		}
		
		return data;
	}
	
	static function cleanHeader( data : String )
	{
		if ( XMLFileReader._headerMatcher.match( data ) )
		{
			return XMLFileReader._headerMatcher.matched( 2 );
		}
		else
		{
			return data;
		}
		
	}
		
	static function readFile( fileName : String )
	{
		try 
		{
			var path = Context.resolvePath( fileName );
			Context.registerModuleDependency( Context.getLocalModule(), path );
			return sys.io.File.getContent( path );
		}
		catch ( error : Dynamic ) 
		{
			return Context.error( 'File loading failed @$fileName $error', Context.currentPos() );
		}
	}
	
	static function _forceCompilation( type : String ) : Void
	{
		trace( type );
		
		if ( XMLFileReader._primType.indexOf( type ) == -1 && XMLFileReader._compiledClass.indexOf( type ) == -1 )
		{
			XMLFileReader._compiledClass.push( type );
			Context.getType( type );
		}
	}
	
	static function _getClassFullyQualifiedNameFromStaticRef( staticRef : String ) : String
	{
		var a : Array<String> = staticRef.split( "." );
		var type : String = a[ a.length - 1 ];
		a.splice( a.length - 1, 1 );
		return a.join( "." );
	}
	
	static function _buildObject() : Void
	{
		
	}
	
	static function _parseNode( applicationContext : AbstractApplicationContext, xml : Xml ) : Void
	{
		var identifier : String = XMLAttributeUtil.getID( xml );
		if ( identifier == null )
		{
			throw new ParsingException( "XMLFileReader encounters parsing error with '" + xml.nodeName + "' node. You must set an id attribute." );
		}

		var type 		: String;
		var args 		: Array<Dynamic>;
		var factory 	: String;
		var singleton 	: String;
		var injectInto	: Bool;
		var mapType		: String;
		var staticRef	: String;
		var ifList		: Array<String>;
		var ifNotList	: Array<String>;

		// Build object.
		type = XMLAttributeUtil.getType( xml );

		if ( type == ContextTypeList.XML )
		{
			args = [];
			args.push( { ownerID:identifier, value:xml.firstElement().toString() } );
			factory = XMLAttributeUtil.getParserClass( xml );
			XMLFileReader._assembler.buildObject( applicationContext, identifier, type, args, factory );
		}
		else
		{
			args 		= ( type == ContextTypeList.HASHMAP || type == ContextTypeList.SERVICE_LOCATOR ) ? XMLParserUtil.getItems( xml ) : XMLParserUtil.getArguments( xml, type );
			factory 	= XMLAttributeUtil.getFactoryMethod( xml );
			singleton 	= XMLAttributeUtil.getSingletonAccess( xml );
			injectInto	= XMLAttributeUtil.getInjectInto( xml );
			mapType 	= XMLAttributeUtil.getMapType( xml );
			staticRef 	= XMLAttributeUtil.getStaticRef( xml );
			ifList 		= XMLParserUtil.getIfList( xml );
			ifNotList 	= XMLParserUtil.getIfNotList( xml );

			if ( type == null )
			{
				type = staticRef != null ? ContextTypeList.UNKNOWN : ContextTypeList.STRING;
			}
			else
			{
				XMLFileReader._forceCompilation( type );
			}
			
			if ( mapType != null )
			{
				XMLFileReader._forceCompilation( mapType );
			}
			
			if ( staticRef != null )
			{
				XMLFileReader._forceCompilation( XMLFileReader._getClassFullyQualifiedNameFromStaticRef( staticRef ) );
			}
			
			XMLFileReader._assembler.buildObject( applicationContext, identifier, type, args, factory, singleton, injectInto, mapType, staticRef, ifList, ifNotList );
			

			// Build property.
			var propertyIterator = xml.elementsNamed( ContextNameList.PROPERTY );
			while ( propertyIterator.hasNext() )
			{
				var property = propertyIterator.next();
				
				XMLFileReader._assembler.buildProperty (
						applicationContext,
						identifier,
						XMLAttributeUtil.getName( property ),
						XMLAttributeUtil.getValue( property ),
						XMLAttributeUtil.getType( property ),
						XMLAttributeUtil.getRef( property ),
						XMLAttributeUtil.getMethod( property ),
						XMLAttributeUtil.getStaticRef( property ),
						XMLParserUtil.getIfList( xml ),
						XMLParserUtil.getIfNotList( xml )
				);
			}

			// Build method call.
			var methodCallIterator = xml.elementsNamed( ContextNameList.METHOD_CALL );
			while( methodCallIterator.hasNext() )
			{
				var methodCallItem = methodCallIterator.next();
				XMLFileReader._assembler.buildMethodCall( applicationContext, identifier, XMLAttributeUtil.getName( methodCallItem ), XMLParserUtil.getMethodCallArguments( methodCallItem ), XMLParserUtil.getIfList( methodCallItem ), XMLParserUtil.getIfNotList( methodCallItem ) );
			}

			// Build channel listener.
			var listenIterator = xml.elementsNamed( ContextNameList.LISTEN );
			while( listenIterator.hasNext() )
			{
				var listener = listenIterator.next();
				var channelName : String = XMLAttributeUtil.getRef( listener );

				if ( channelName != null )
				{
					var listenerArgs : Array<DomainListenerVOArguments> = XMLParserUtil.getEventArguments( listener );
					XMLFileReader._assembler.buildDomainListener( applicationContext, identifier, channelName, listenerArgs, XMLParserUtil.getIfList( listener ), XMLParserUtil.getIfNotList( listener ) );
				}
				else
				{
					throw new ParsingException( "XMLFileReader encounters parsing error with '" + xml.nodeName + "' node, 'ref' attribute is mandatory in a 'listen' node." );
				}
			}
		}
	}
	#end
	
	macro public static function readXmlFile( fileName : String ) : ExprOf<String> 
	{
        var data = XMLFileReader.readFile( fileName );
		data = XMLFileReader.checkForInclude( data );
		
        try 
		{
			var xml : Xml = Xml.parse( data );
			XMLFileReader._compiledClass = [];
			
			XMLFileReader._assembler 	= new CompileTimeApplicationAssembler();
			var compileTimeFactory 		= new CompileTimeCoreFactory();
			var applicationContext 		= new AbstractApplicationContext( compileTimeFactory, "name" );
			
			var iterator = xml.firstElement().elements();
			while ( iterator.hasNext() )
			{
				XMLFileReader._parseNode( applicationContext, iterator.next() );
			}
			
			
		}
		catch ( error : Dynamic ) 
		{
            Context.error( 'Xml parsing failed @$fileName $error', Context.currentPos() );
        }
		
        return Context.makeExpr( data, Context.currentPos() );
    }
}