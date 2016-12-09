package hex.compiler.factory;

import haxe.macro.Context;
import hex.error.PrivateConstructorException;
import hex.util.ArrayUtil;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class FactoryUtil 
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }
	
	static public function checkTypeParamsExist( typeParams : String, filePosition : haxe.macro.Expr.Position ) : Void
	{
		try
		{
			var prefix = 'var a:';
			var exp = Context.parseInlineString( prefix + typeParams, Context.currentPos() );
			var t = Context.typeof( exp );
		}
		catch( e: Dynamic )
		{
			Context.error( "" + e, filePosition );
		}
	}
}