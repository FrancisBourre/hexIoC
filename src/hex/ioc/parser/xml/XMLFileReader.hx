package hex.ioc.parser.xml;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author Francis Bourre
 */
class XMLFileReader
{
	macro public static function readXmlFile( fileName : String ) : ExprOf<String> 
	{
        var data = null;
		
		try 
		{
			var path = Context.resolvePath( fileName );
			Context.registerModuleDependency( Context.getLocalModule(), path );
			data = sys.io.File.getContent( path );
		}
		catch ( error : Dynamic ) 
		{
			Context.error( 'File loading failed @$fileName $error', Context.currentPos() );
		}
		
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