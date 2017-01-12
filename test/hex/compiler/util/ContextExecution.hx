package hex.compiler.util;

#if macro
import haxe.macro.Expr;
import haxe.macro.Expr.Field;

/**
 * @author Francis Bourre
 */

typedef ContextExecution =
{
	
	var field 		: Field;
	var body 		: Expr;
	var fileName 	: String;
}
#end