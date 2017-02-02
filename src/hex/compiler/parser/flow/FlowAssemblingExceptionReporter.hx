package hex.compiler.parser.flow;

#if macro
import haxe.macro.Expr;
import hex.compiletime.error.IExceptionReporter;

/**
 * ...
 * @author Francis Bourre
 */
class FlowAssemblingExceptionReporter implements IExceptionReporter<Expr>
{
	public function new() {}

	public function report( message : String, ?position : Position ) : Void
	{
		haxe.macro.Context.error( message, position != null ? position : haxe.macro.Context.currentPos() );
	}
}
#end