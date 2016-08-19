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
class XmlDSLReader
{
	static var _includeMatcher 	: EReg = ~/<include.*?file=("|')([^"']+)\1.*?(?:(?:\/>)|(?:>[\W\w\t\r\n]*?<\/include *>))/g;
	static var _headerMatcher 	: EReg = ~/((?:<\?xml[^>]+>\s*)?<([a-zA-Z0-9-_:]+)[^>]*>[\r\n]?)([\s\S]*)<\/\2\s*>/;
	static var _cleanupMatcher 	: EReg = ~/<!--[\s\S]*?-->/g;
	
	function new() 
	{
		
	}
	
	#if macro
	static function _checkForInclude( xmlRawData : XmlDSLData, ?preprocessingVariables : Expr, ?conditionalVariablesChecker : ConditionalVariablesChecker )
	{
		var data = xmlRawData.data;
		//xmlRawData.data = XmlDSLReader._cleanupMatcher.replace( xmlRawData.data, "" );
		if ( XmlDSLReader._includeMatcher.match( xmlRawData.data ) )
		{
			var f = function( eReg: EReg ) : String
			{
				var xml 				= Xml.parse( "<root>" + XmlDSLReader._includeMatcher.matched( 0 ) + "</root>" );
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
					var fileName 	= XmlDSLReader._includeMatcher.matched( 2 );
					var xrd 		= XmlDSLReader._readFile( fileName, preprocessingVariables );
					XmlDSLReader._cleanHeader( xrd );
					xrd = XmlDSLReader._checkForInclude( xrd, preprocessingVariables, conditionalVariablesChecker );
					return xrd.data;
				}
				else
				{
					return "";
				}
			}

			xmlRawData.data = XmlDSLReader._includeMatcher.map( xmlRawData.data, f );
		}

		return xmlRawData;
	}
	
	static function _cleanHeader( xrd : XmlDSLData )
	{
		if ( XmlDSLReader._headerMatcher.match( xrd.data ) )
		{
			xrd.data = XmlDSLReader._headerMatcher.matched( 3 );
			xrd.length = xrd.data.length;
		}
	}
	
	static function _readFile( fileName : String, ?preprocessingVariables : Expr ) : XmlDSLData
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
			
			//instantiate XmlDSLData result
			var result = 	{ 	
								data: 				data,
								length: 			data.length, 
								path: 				path,
							};
			
			return result;
		}
		catch ( error : Dynamic )
		{
			return Context.error( 'File loading failed @$fileName $error', Context.currentPos() );
		}
	}
	
	public static function readFile( fileName : String, ?preprocessingVariables : Expr ) : XmlDSLData
	{
		try
		{
			//resolve
			var path = Context.resolvePath( fileName );
			Context.registerModuleDependency( Context.getLocalModule(), path );
			
			//read data
			var data = sys.io.File.getContent( path );
			
			//instantiate XmlDSLData result
			var result = 	{ 	
								data: 				data,
								length: 			data.length, 
								path: 				path,
							};
			
			return result;
		}
		catch ( error : Dynamic )
		{
			return Context.error( 'File loading failed @$fileName $error', Context.currentPos() );
		}
	}
	
	public static function readXmlFile( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariablesChecker : ConditionalVariablesChecker ) : XmlDSLData
	{
		var xmlRawData = XmlDSLReader._readFile( fileName, preprocessingVariables );
		xmlRawData = XmlDSLReader._checkForInclude( xmlRawData, preprocessingVariables, conditionalVariablesChecker );
		return xmlRawData;
	}
	#end
}
