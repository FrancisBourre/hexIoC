package hex.ioc.parser.xml;

import hex.ioc.parser.preprocess.Preprocessor;
import hex.ioc.parser.preprocess.MacroPreprocessor;
import hex.ioc.parser.xml.XMLFileReader;
import haxe.macro.Context;
import haxe.macro.Expr;
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

	static var _rootFolder		: String = "";
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
			var path = Context.resolvePath( XMLFileReader._rootFolder + fileName );
			Context.registerModuleDependency( Context.getLocalModule(), path );
			return sys.io.File.getContent( path );
		}
		catch ( error : Dynamic )
		{
			return Context.error( 'File loading failed @$fileName $error', Context.currentPos() );
		}
	}

	static function _forceCompilation( type : String ) : Bool
	{
		if ( type != null && XMLFileReader._primType.indexOf( type ) == -1 && XMLFileReader._compiledClass.indexOf( type ) == -1 )
		{
			XMLFileReader._compiledClass.push( type );
			Context.getType( type );
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
			XMLFileReader._forceCompilation( XMLFileReader._getClassFullyQualifiedNameFromStaticRef( staticRef ) );
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
			XMLFileReader._forceCompilation( arg.value );
			return true;
		}
		else
		{
			return false;
		}
	}

	static function _parseNode( xml : Xml ) : Void
	{
		var identifier : String = XMLAttributeUtil.getID( xml );
		if ( identifier == null )
		{
			throw new ParsingException( "XMLFileReader encounters parsing error with '" + xml.nodeName + "' node. You must set an id attribute." );
		}

		var type 		: String;
		var args 		: Array<Dynamic>;
		var mapType		: String;
		var staticRef	: String;

		// Build object.
		type = XMLAttributeUtil.getType( xml );

		if ( type == ContextTypeList.XML )
		{
			XMLFileReader._forceCompilation( XMLAttributeUtil.getParserClass( xml ) );
		}
		else
		{
			args 		= ( type == ContextTypeList.HASHMAP || type == ContextTypeList.SERVICE_LOCATOR ) ? XMLParserUtil.getItems( xml ) : XMLParserUtil.getArguments( xml, type );

			if ( type == ContextTypeList.HASHMAP || type == ContextTypeList.SERVICE_LOCATOR )
			{
				args = XMLParserUtil.getItems( xml );
				for ( arg in args )
				{
					XMLFileReader._includeClass( arg.key );
					XMLFileReader._includeClass( arg.value );
				}
			}
			else
			{
				args = XMLParserUtil.getArguments( xml, type );
				for ( arg in args )
				{
					if ( !XMLFileReader._includeStaticRef( arg.staticRef ) )
					{
						XMLFileReader._includeClass( arg );
					}
				}
			}

			XMLFileReader._forceCompilation( type );
			XMLFileReader._forceCompilation( XMLAttributeUtil.getMapType( xml ) );
			XMLFileReader._includeStaticRef( XMLAttributeUtil.getStaticRef( xml ) );

			// Build property.
			var propertyIterator = xml.elementsNamed( ContextNameList.PROPERTY );
			while ( propertyIterator.hasNext() )
			{
				XMLFileReader._includeStaticRef( XMLAttributeUtil.getStaticRef( propertyIterator.next() ) );
			}

			// Build method call.
			var methodCallIterator = xml.elementsNamed( ContextNameList.METHOD_CALL );
			while( methodCallIterator.hasNext() )
			{
				var methodCallItem = methodCallIterator.next();

				args = XMLParserUtil.getMethodCallArguments( methodCallItem );
				for ( arg in args )
				{
					if ( !XMLFileReader._includeStaticRef( arg.staticRef ) )
					{
						XMLFileReader._includeClass( arg );
					}
				}
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
					for ( listenerArg in listenerArgs )
					{
						XMLFileReader._includeStaticRef( listenerArg.staticRef );
						XMLFileReader._forceCompilation( listenerArg.strategy );
					}
				}
				else
				{
					throw new ParsingException( "XMLFileReader encounters parsing error with '" + xml.nodeName + "' node, 'ref' attribute is mandatory in a 'listen' node." );
				}
			}
		}
	}
	#end

	macro public static function readXmlFile( fileName : String, ?m : Expr ) : ExprOf<String>
	{
		var data = XMLFileReader.readFile( fileName );
		data = XMLFileReader.checkForInclude( data );
		data = MacroPreprocessor.parse( data, m );
		
		try
		{
			var xml : Xml = Xml.parse( data );
			XMLFileReader._compiledClass = [];

			var iterator = xml.firstElement().elements();
			while ( iterator.hasNext() )
			{
				XMLFileReader._parseNode( iterator.next() );
			}


		}
		catch ( error : Dynamic )
		{
			Context.error( 'Xml parsing failed @$fileName $error', Context.currentPos() );
		}

		return macro $v{ data };
	}
}