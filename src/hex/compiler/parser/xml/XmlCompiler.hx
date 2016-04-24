package hex.compiler.parser.xml;

import com.tenderowls.xml176.Xml176Parser;
import haxe.ds.GenericStack;
import hex.domain.Domain;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.ApplicationAssembler;
import hex.compiler.assembler.CompileTimeApplicationAssembler;
import hex.compiler.core.CompileTimeCoreFactory;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.parser.preprocess.Preprocessor;
import hex.ioc.parser.preprocess.MacroPreprocessor;
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.ioc.core.ContextNameList;
import hex.ioc.core.ContextTypeList;
import hex.ioc.error.ParsingException;
import hex.ioc.parser.xml.XMLAttributeUtil;
import hex.ioc.parser.xml.XMLParserUtil;
import hex.ioc.vo.DomainListenerVOArguments;

using StringTools;

/**
 * ...
 * @author Francis Bourre
 */
class XmlCompiler
{
	static var _includeMatcher 	: EReg = ~/<include.*?file=("|')([^"']+)\1.*?(?:(?:\/>)|(?:>[\W\w\t\r\n]*?<\/include *>))/g;
	static var _headerMatcher 	: EReg = ~/((?:<\?xml[^>]+>\s*)<([a-zA-Z0-9-_:]+)[^>]*>[\r\n]?)([\s\S]*)<\/\2\s*>/;

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

	static var _assembler 		: CompileTimeApplicationAssembler;
	
	#if macro
	static function checkForInclude( xmlRawData : XMLRawData, xrdStack : GenericStack<XMLRawData>, ?m : Expr )
	{
		xrdStack.add( xmlRawData );
		
		if ( XmlCompiler._includeMatcher.match( xmlRawData.data ) )
		{
			var f = function( eReg: EReg ) : String
			{
				var fileName 	= XmlCompiler._includeMatcher.matched( 2 );
				var xrd 		= XmlCompiler.readFile( fileName, xmlRawData, XmlCompiler._includeMatcher.matchedPos(), m );
				XmlCompiler.cleanHeader( xrd );

				xrd = checkForInclude( xrd, xrdStack, m );
				return xrd.data;
			}

			xmlRawData.data = XmlCompiler._includeMatcher.map( xmlRawData.data, f );
		}

		return xmlRawData;
	}

	static function cleanHeader( xrd : XMLRawData )
	{
		if ( XmlCompiler._headerMatcher.match( xrd.data ) )
		{
			xrd.header = XmlCompiler._headerMatcher.matched( 1 ).length;
			xrd.data = XmlCompiler._headerMatcher.matched( 3 );
			xrd.length = xrd.data.length;
		}
	}

	static function readFile( fileName : String, parent : XMLRawData = null, includePosition : { pos : Int, len : Int } = null, ?preProcessData : Expr ) : XMLRawData
	{
		try
		{
			//resolve
			var path = Context.resolvePath( fileName );
			Context.registerModuleDependency( Context.getLocalModule(), path );
			
			//read data
			var data = sys.io.File.getContent( path );
			
			//preprocess
			data = MacroPreprocessor.parse( data, preProcessData );
			
			//instantiate XMLRawData result
			var result = 	{ 	
								data: 				data,
								length: 			data.length, 
								path: 				path,
								
								parent: 			parent, 
								children: 			[], 
								
								header: 			0, 
								position: 			( includePosition == null ? 0 : includePosition.pos ), 
								includePosition: 	includePosition,

								absLength: 			0, 
								absPosition: 		0, 
								absIncludeLength: 	( includePosition == null ? 0 : includePosition.len )
							};
			
			//set child to parent
			if ( parent != null )
			{
				parent.children.push( result );
			}
			
			return result;
		}
		catch ( error : Dynamic )
		{
			if ( parent == null )
			{
				return Context.error( 'File loading failed @$fileName $error', Context.currentPos() );
			}
			else
			{
				return Context.error( '$error', Context.makePosition( {min: includePosition.pos + parent.header, max: includePosition.pos + includePosition.len + parent.header, file: parent.path } ) );
			}
		}
	}

	static function _forceCompilation( type : String ) : Bool
	{
		if ( type != null && XmlCompiler._primType.indexOf( type ) == -1 && XmlCompiler._compiledClass.indexOf( type ) == -1 )
		{
			XmlCompiler._compiledClass.push( type );
			try
			{
				Context.getType( type );
			}
			catch ( e : haxe.macro.Error )
			{
				Context.error( e.message, e.pos );
			}
			
			return true;
		}
		else
		{
			return false;
		}
	}

	static function _getClassFullyQualifiedNameFromStaticRef( staticRef : String ) : String
	{
		var a : Array<String> = staticRef.split( "." );
		var type : String = a[ a.length - 1 ];
		a.splice( a.length - 1, 1 );
		return a.join( "." );
	}

	static function  _includeStaticRef( staticRef : String ) : Bool
	{
		if ( staticRef != null )
		{
			XmlCompiler._forceCompilation( XmlCompiler._getClassFullyQualifiedNameFromStaticRef( staticRef ) );
			return true;
		}
		else
		{
			return false;
		}
	}

	static function _includeClass( arg : Dynamic ) : Bool
	{
		if ( arg.type == ContextTypeList.CLASS )
		{
			XmlCompiler._forceCompilation( arg.value );
			return true;
		}
		else
		{
			return false;
		}
	}
	
	static function makePosition( pos : { from: Int, ?to: Int }, collection : Array<XMLRawData> ) : haxe.macro.Position
	{
		var element = findEntry( pos, collection );
		
		var posFrom = pos.from - element.absPosition + element.header;
		var posTo 	= pos.to - element.absPosition + element.header;
		
		var childOffset = 0;
		for ( child in element.children )
		{
			if ( child.absPosition < pos.from )
			{
				childOffset += child.absIncludeLength - child.absLength;
			}
		}
		
		return Context.makePosition( { min: posFrom + childOffset, max: posTo + childOffset, file: element.path } );
	}
	
	static function findEntry( pos, collection : Array<XMLRawData> )
	{
		var result : XMLRawData = null;
		
		for ( element in collection )
		{
			if ( pos.from >= element.absPosition && pos.to < element.absPosition + element.absLength )
			{
				if ( result == null || element.absPosition > result.absPosition )
				{
					result = element;
				}
			}
		}

		return result;
	}
	
	static function makePositionFromNode( xml : Xml, doc : Xml176Document, collection : Array<XMLRawData> ) : haxe.macro.Position
	{
		return makePosition( doc.getNodePosition( xml ), collection );
	}
	
	static function makePositionFromAttribute( xml : Xml, doc : Xml176Document, collection : Array<XMLRawData>, attributeName : String ) : haxe.macro.Position
	{
		return makePosition( doc.getAttrPosition( xml, attributeName ), collection );
	}

	static function _parseNode( applicationContext : AbstractApplicationContext, xml : Xml, doc : Xml176Document, xrd : XMLRawData, xrdCollection : Array<XMLRawData> ) : Void
	{
		var identifier : String = xml.get( ContextAttributeList.ID );
		if ( identifier == null )
		{
			Context.error( "XmlCompiler parsing error with '" + xml.nodeName + "' node, 'id' attribute not found.", makePositionFromNode( xml, doc, xrdCollection ) );
		}

		var type 		: String;
		var args 		: Array<Dynamic>;
		var mapType		: String;
		var staticRef	: String;
		
		var factory 	: String;
		var singleton 	: String;
		var injectInto	: Bool;
		var ifList		: Array<String>;
		var ifNotList	: Array<String>;

		// Build object.
		type = xml.get( ContextAttributeList.TYPE );

		if ( type == ContextTypeList.XML )
		{
			args = [];
			args.push( { ownerID: identifier, value: xml.firstElement().toString() } );
			factory = xml.get( ContextAttributeList.PARSER_CLASS );
			XmlCompiler._assembler.buildObject( applicationContext, identifier, type, args, factory );
			
			XmlCompiler._forceCompilation( factory );
		}
		else
		{
			factory 	= xml.get( ContextAttributeList.FACTORY );
			singleton 	= xml.get( ContextAttributeList.SINGLETON_ACCESS );
			injectInto	= xml.get( ContextAttributeList.INJECT_INTO ) == "true";
			mapType 	= xml.get( ContextAttributeList.MAP_TYPE );
			staticRef 	= xml.get( ContextAttributeList.STATIC_REF );
			ifList 		= XMLParserUtil.getIfList( xml );
			ifNotList 	= XMLParserUtil.getIfNotList( xml );
			
			if ( type == null )
			{
				type = staticRef != null ? ContextTypeList.INSTANCE : ContextTypeList.STRING;
			}

			if ( type == ContextTypeList.HASHMAP || type == ContextTypeList.SERVICE_LOCATOR )
			{
				args = XMLParserUtil.getItems( xml );
				for ( arg in args )
				{
					XmlCompiler._includeClass( arg.key );
					XmlCompiler._includeClass( arg.value );
				}
			}
			else
			{
				args = XMLParserUtil.getArguments( xml, type );
				for ( arg in args )
				{
					if ( !XmlCompiler._includeStaticRef( arg.staticRef ) )
					{
						XmlCompiler._includeClass( arg );
					}
				}
			}

			try
			{
				XmlCompiler._forceCompilation( type );
			}
			catch ( e : String )
			{
				Context.error( "XmlCompiler parsing error with '" + xml.nodeName + "' node, '" + type + "' type not found.", makePositionFromAttribute( xml, doc, xrdCollection, ContextAttributeList.TYPE ) );
			}
			
			XmlCompiler._forceCompilation( mapType );
			XmlCompiler._includeStaticRef( staticRef );
			
			XmlCompiler._assembler.buildObject( applicationContext, identifier, type, args, factory, singleton, injectInto, mapType, staticRef, ifList, ifNotList );

			// Build property.
			var propertyIterator = xml.elementsNamed( ContextNameList.PROPERTY );
			while ( propertyIterator.hasNext() )
			{
				var property = propertyIterator.next();
				XmlCompiler._includeStaticRef( property.get( ContextAttributeList.STATIC_REF ) );
				
				XmlCompiler._assembler.buildProperty (
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

				args = XMLParserUtil.getMethodCallArguments( methodCallItem );
				for ( arg in args )
				{
					if ( !XmlCompiler._includeStaticRef( arg.staticRef ) )
					{
						XmlCompiler._includeClass( arg );
					}
				}
				
				XmlCompiler._assembler.buildMethodCall( applicationContext, identifier, xml.get( ContextAttributeList.NAME ), XMLParserUtil.getMethodCallArguments( methodCallItem ), XMLParserUtil.getIfList( methodCallItem ), XMLParserUtil.getIfNotList( methodCallItem ) );
			}

			// Build channel listener.
			var listenIterator = xml.elementsNamed( ContextNameList.LISTEN );
			while( listenIterator.hasNext() )
			{
				var listener = listenIterator.next();
				var channelName : String = listener.get( ContextAttributeList.REF );

				if ( channelName != null )
				{
					var listenerArgs : Array<DomainListenerVOArguments> = XMLParserUtil.getEventArguments( listener );
					for ( listenerArg in listenerArgs )
					{
						XmlCompiler._includeStaticRef( listenerArg.staticRef );
						XmlCompiler._forceCompilation( listenerArg.strategy );
					}
					
					XmlCompiler._assembler.buildDomainListener( applicationContext, identifier, channelName, listenerArgs, XMLParserUtil.getIfList( listener ), XMLParserUtil.getIfNotList( listener ) );
				}
				else
				{
					Context.error( "XmlCompiler parsing error with '" + xml.nodeName + "' node, 'ref' attribute is mandatory in a 'listen' node.", makePositionFromNode( listener, doc, xrdCollection ) );
				}
			}
		}
	}
	
	static function getFieldExpression( className : String )
	{
		Context.getType( className );
		return className.split( "." );
	}
	
	static function getTypePath( className : String ) : TypePath
	{
		Context.getType( className );
		var pack = className.split( "." );
		var className = pack[ pack.length -1 ];
		pack.splice( pack.length - 1, 1 );
		return { pack: pack, name: className };
	}
	
	static function getApplicationContext( doc : Xml176Document, xrdCollection : Array<XMLRawData> ) : ExprOf<AbstractApplicationContext>
	{
		var xml = doc.document.firstElement();
		
		var applicationContextClass = null;
		var applicationContextClassName : String = xml.get( ContextAttributeList.TYPE );
		
		if ( applicationContextClassName != null )
		{
			try
			{
				applicationContextClass = getFieldExpression( applicationContextClassName );
			}
			catch ( error : Dynamic )
			{
				Context.error( "XmlCompiler failed to instantiate applicationContext class typed '" + applicationContextClassName + "'", makePositionFromAttribute( xml, doc, xrdCollection, ContextAttributeList.TYPE ) );
			}
		}
		
		var applicationContextName : String = xml.get( "name" );
		if ( applicationContextName == null )
		{
			Context.error( "XmlCompiler failed to retrieve applicationContext name. You should add 'name' attribute to the root of your xml context", makePositionFromNode( xml, doc, xrdCollection ) );
		}
		
		var expr;
		if ( applicationContextClass != null )
		{
			expr = macro @:mergeBlock { var applicationContext = applicationAssembler.getApplicationContext( $v{ applicationContextName }, $p { applicationContextClass } ); };
		}
		else
		{
			expr = macro @:mergeBlock { var applicationContext = applicationAssembler.getApplicationContext( $v{ applicationContextName } ); };
		}

		
		return expr;
	}
	#end
	
	static function updateParentSize( xrd : XMLRawData, lengthOffset : UInt, includeLengthOffset : UInt )
	{
		var parent = xrd.parent;
		parent.absLength += lengthOffset;
		parent.absIncludeLength += includeLengthOffset;
		
		if ( parent.parent != null )
		{
			updateParentSize( parent, lengthOffset, includeLengthOffset );
		}
	}
	
	static function updateChildPosition( xrd : XMLRawData, offset : UInt ) : Void
	{
		for ( child in xrd.children )
		{
			child.absPosition += offset;
			if ( child.children.length > 0 )
			{
				updateChildPosition( child, offset );
			}
		}
	}
	
	macro public static function readXmlFile( fileName : String, ?m : Expr ) : ExprOf<ApplicationAssembler>
	{
		var xrdStack = new GenericStack<XMLRawData>();
		
		var xmlRawData = XmlCompiler.readFile( fileName, null, null, m );
		xmlRawData = XmlCompiler.checkForInclude( xmlRawData, xrdStack );
		
		var xrdCollection : Array<XMLRawData> = [];
		var i = 0;
		while ( !xrdStack.isEmpty() )
		{
			var xrd 		= xrdStack.pop();
			xrd.absLength 	+= xrd.length;
			xrd.absPosition += xrd.position;

			if ( xrd.parent != null )
			{
				updateParentSize( xrd, xrd.length, xrd.absIncludeLength );
			}
			
			if ( xrd.children.length > 0 )
			{
				updateChildPosition( xrd, xrd.position );
			}

			xrdCollection.push( xrd );
		}

		var doc;
		
		try
		{
			doc = Xml176Parser.parse( xmlRawData.data, xmlRawData.path );
			XmlCompiler._compiledClass = [];
			
			//
			XmlCompiler._assembler 		= new CompileTimeApplicationAssembler();
			var applicationContext 		= XmlCompiler._assembler.getApplicationContext( "name" );
			
			//
			var iterator = doc.document.firstElement().elements();
			while ( iterator.hasNext() )
			{
				XmlCompiler._parseNode( applicationContext, iterator.next(), doc, xmlRawData, xrdCollection );
			}

		}
		catch ( error : haxe.macro.Error )
		{
			Context.error( 'Xml parsing failed @$fileName $error', Context.currentPos() );
		}
		
		var assembler = XmlCompiler._assembler;

		//Create runtime applicationAssembler
		var applicationAssemblerTypePath = getTypePath( Type.getClassName( ApplicationAssembler ) );
		assembler.addExpression( macro @:mergeBlock { var applicationAssembler = new $applicationAssemblerTypePath(); } );
		
		//Create runtime applicationContext
		assembler.addExpression( getApplicationContext( doc, xrdCollection ) );
		
		//Create runtime coreFactory
		assembler.addExpression( macro @:mergeBlock { var coreFactory = applicationContext.getCoreFactory(); } );

		//build
		XmlCompiler._assembler.buildEverything();
		
		//return program
		assembler.addExpression( macro { applicationAssembler; } );
		return assembler.getMainExpression();
	}
}
