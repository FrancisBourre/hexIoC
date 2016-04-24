package hex.ioc.parser.xml;

import com.tenderowls.xml176.Xml176Parser;
import haxe.ds.GenericStack;
import hex.compiler.parser.xml.XMLRawData;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.parser.preprocess.Preprocessor;
import hex.ioc.parser.preprocess.MacroPreprocessor;
import hex.ioc.parser.xml.XMLFileReader;
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.ioc.core.ContextNameList;
import hex.ioc.core.ContextTypeList;
import hex.ioc.error.ParsingException;
import hex.ioc.vo.DomainListenerVOArguments;

using StringTools;

/**
 * ...
 * @author Francis Bourre
 */
class XMLFileReader
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

	#if macro
	static function checkForInclude( xmlRawData : XMLRawData, xrdStack : GenericStack<XMLRawData>, ?m : Expr )
	{
		xrdStack.add( xmlRawData );
		
		if ( XMLFileReader._includeMatcher.match( xmlRawData.data ) )
		{
			var f = function( eReg: EReg ) : String
			{
				var fileName 	= XMLFileReader._includeMatcher.matched( 2 );
				var xrd 		= XMLFileReader.readFile( fileName, xmlRawData, XMLFileReader._includeMatcher.matchedPos(), m );
				XMLFileReader.cleanHeader( xrd );

				xrd = checkForInclude( xrd, xrdStack, m );
				return xrd.data;
			}

			xmlRawData.data = XMLFileReader._includeMatcher.map( xmlRawData.data, f );
		}

		return xmlRawData;
	}

	static function cleanHeader( xrd : XMLRawData )
	{
		if ( XMLFileReader._headerMatcher.match( xrd.data ) )
		{
			xrd.header = XMLFileReader._headerMatcher.matched( 1 ).length;
			xrd.data = XMLFileReader._headerMatcher.matched( 3 );
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
		if ( type != null && XMLFileReader._primType.indexOf( type ) == -1 && XMLFileReader._compiledClass.indexOf( type ) == -1 )
		{
			XMLFileReader._compiledClass.push( type );
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

	static function _parseNode( xml : Xml, doc : Xml176Document, xrd : XMLRawData, xrdCollection : Array<XMLRawData> ) : Void
	{
		var identifier : String = xml.get( ContextAttributeList.ID );
		if ( identifier == null )
		{
			Context.error( "XMLFileReader parsing error with '" + xml.nodeName + "' node, 'id' attribute not found.", makePositionFromNode( xml, doc, xrdCollection ) );
		}

		var type 		: String;
		var args 		: Array<Dynamic>;
		var mapType		: String;
		var staticRef	: String;

		// Build object.
		type = xml.get( ContextAttributeList.TYPE );

		if ( type == ContextTypeList.XML )
		{
			XMLFileReader._forceCompilation( xml.get( ContextAttributeList.PARSER_CLASS ) );
		}
		else
		{
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

			try
			{
				XMLFileReader._forceCompilation( type );
			}
			catch ( e : String )
			{
				Context.error( "XMLFileReader parsing error with '" + xml.nodeName + "' node, '" + type + "' type not found.", makePositionFromAttribute( xml, doc, xrdCollection, ContextAttributeList.TYPE ) );
			}
			
			XMLFileReader._forceCompilation( xml.get( ContextAttributeList.MAP_TYPE ) );
			XMLFileReader._includeStaticRef( xml.get( ContextAttributeList.STATIC_REF ) );

			// Build property.
			var propertyIterator = xml.elementsNamed( ContextNameList.PROPERTY );
			while ( propertyIterator.hasNext() )
			{
				XMLFileReader._includeStaticRef( propertyIterator.next().get( ContextAttributeList.STATIC_REF ) );
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
				var channelName : String = listener.get( ContextAttributeList.REF );

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
					Context.error( "XMLFileReader parsing error with '" + xml.nodeName + "' node, 'ref' attribute is mandatory in a 'listen' node.", makePositionFromNode( listener, doc, xrdCollection ) );
				}
			}
		}
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
	
	macro public static function readXmlFile( fileName : String, ?m : Expr ) : ExprOf<String>
	{
		var xrdStack = new GenericStack<XMLRawData>();
		
		var xmlRawData = XMLFileReader.readFile( fileName, null, null, m );
		xmlRawData = XMLFileReader.checkForInclude( xmlRawData, xrdStack );
		
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

		try
		{
			var doc = Xml176Parser.parse( xmlRawData.data, xmlRawData.path );
			XMLFileReader._compiledClass = [];

			var iterator = doc.document.firstElement().elements();
			while ( iterator.hasNext() )
			{
				XMLFileReader._parseNode( iterator.next(), doc, xmlRawData, xrdCollection );
			}

		}
		catch ( error : haxe.macro.Error )
		{
			Context.error( 'Xml parsing failed @$fileName $error', Context.currentPos() );
		}

		return macro $v{ xmlRawData.data };
	}
}
