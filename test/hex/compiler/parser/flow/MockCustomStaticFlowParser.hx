package hex.compiler.parser.flow;

import hex.compiler.core.CompileTimeSettings;
import hex.compiletime.flow.parser.FlowExpressionParser;

/**
 * ...
 * @author Francis Bourre
 */
class MockCustomStaticFlowParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	macro public static function prepareCompiler() : haxe.macro.Expr.ExprOf<Bool>
	{
		FlowExpressionParser.parser.methodParser.set( 'add', hex.compiletime.flow.parser.custom.AddParser.parse );
		CompileTimeSettings.factoryMap.set( 'haxe.macro.Expr', hex.compiletime.factory.CodeFactory.build );
		return macro true;
	}
}