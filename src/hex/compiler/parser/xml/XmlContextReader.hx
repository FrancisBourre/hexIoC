package hex.compiler.parser.xml;

import haxe.ds.GenericStack;
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.compiler.parser.preprocess.MacroPreprocessor;
import hex.ioc.assembler.ConditionalVariablesChecker;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.parser.xml.XMLParserUtil;

/**
 * ...
 * @author Francis Bourre
 */
class XmlContextReader
{
	static var _includeMatcher 	: EReg = ~/<include.*?file=("|')([^"']+)\1.*?(?:(?:\/>)|(?:>[\W\w\t\r\n]*?<\/include *>))/g;
	static var _headerMatcher 	: EReg = ~/((?:<\?xml[^>]+>\s*)?<([a-zA-Z0-9-_:]+)[^>]*>[\r\n]?)([\s\S]*)<\/\2\s*>/;
	
	function new() 
	{
		
	}
	
	#if macro
	static function checkForInclude( xmlRawData : XMLRawData, xrdStack : GenericStack<XMLRawData>, ?preprocessingVariables : Expr, ?conditionalVariablesChecker : ConditionalVariablesChecker )
	{
		xrdStack.add( xmlRawData );
		
		if ( XmlContextReader._includeMatcher.match( xmlRawData.data ) )
		{
			var f = function( eReg: EReg ) : String
			{
				var xml 				= Xml.parse( "<root>" + XmlContextReader._includeMatcher.matched( 0 ) + "</root>" );
				var element 			= xml.firstElement().firstChild();

				var ifList 				= XMLParserUtil.getIfList( element );
				var ifNotList 			= XMLParserUtil.getIfNotList( element );
				var includeIsAllowed 	= false;
				
				if ( conditionalVariablesChecker != null )
				{
					if ( conditionalVariablesChecker.allowsIfList( ifList ) && conditionalVariablesChecker.allowsIfNotList( ifNotList ) )
					{
						includeIsAllowed = true;
					}
				}
				else
				{
					includeIsAllowed = true;
				}
				
				if ( includeIsAllowed )
				{
					var fileName 	= XmlContextReader._includeMatcher.matched( 2 );
					var xrd 		= XmlContextReader.readFile( fileName, xmlRawData, XmlContextReader._includeMatcher.matchedPos(), preprocessingVariables );
					XmlContextReader.cleanHeader( xrd );
					xrd = checkForInclude( xrd, xrdStack, preprocessingVariables, conditionalVariablesChecker );
					return xrd.data;
				}
				else
				{
					return "";
				}
			}

			xmlRawData.data = XmlContextReader._includeMatcher.map( xmlRawData.data, f );
		}

		return xmlRawData;
	}

	static function cleanHeader( xrd : XMLRawData )
	{
		if ( XmlContextReader._headerMatcher.match( xrd.data ) )
		{
			xrd.header = XmlContextReader._headerMatcher.matched( 1 ).length;
			xrd.data = XmlContextReader._headerMatcher.matched( 3 );
			xrd.length = xrd.data.length;
		}
	}

	static function readFile( fileName : String, parent : XMLRawData = null, includePosition : { pos : Int, len : Int } = null, ?preprocessingVariables : Expr ) : XMLRawData
	{
		try
		{
			//resolve
			var path = Context.resolvePath( fileName );
			Context.registerModuleDependency( Context.getLocalModule(), path );
			
			//read data
			var data = sys.io.File.getContent( path );
			
			//preprocess
			data = MacroPreprocessor.parse( data, preprocessingVariables );
			
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
	
	public static function readXmlFile( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariablesChecker : ConditionalVariablesChecker ) : {xrd:XMLRawData, collection:Array<XMLRawData>}
	{
		var xrdStack = new GenericStack<XMLRawData>();
		
		var xmlRawData = XmlContextReader.readFile( fileName, null, null, preprocessingVariables );
		xmlRawData = XmlContextReader.checkForInclude( xmlRawData, xrdStack, preprocessingVariables, conditionalVariablesChecker );
		
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
		
		return { xrd: xmlRawData, collection: xrdCollection };
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
}
