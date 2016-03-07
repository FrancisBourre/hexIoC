package hex.ioc.parser.xml;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author Francis Bourre
 */
class XMLFileReader
{
	static var _includeMatcher 	: EReg = ~/<include.*?file=("|')([^"']+)\1.*?(?:(?:\/>)|(?:>[\W\w\t\r\n]*?<\/import *>))/g;
	static var _headerMatcher 	: EReg = ~/(?:<\?xml[^>]+>\s*)<([a-zA-Z0-9-_:]+)[^>]*>([\s\S]*)<\/\1\s*>/;
	
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
	#end
	
	macro public static function readXmlFile( fileName : String ) : ExprOf<String> 
	{
        var data = XMLFileReader.readFile( fileName );
		data = XMLFileReader.checkForInclude( data );
		
        try 
		{
			Xml.parse( data );
		}
		catch ( error : Dynamic ) 
		{
            Context.error( 'Xml parsing failed @$fileName $error', Context.currentPos() );
        }
		
        return Context.makeExpr( data, Context.currentPos() );
    }
}