package hex.compiler.factory;

import haxe.macro.Expr;
import hex.compiler.vo.FactoryVO;
import hex.error.PrivateConstructorException;

/**
 * ...
 * @author Francis Bourre
 */
class ArgumentFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( );
    }

	#if macro
	static public function build( factoryVO : FactoryVO ) : Array<Expr>
	{
		var result 			= [];
		var factory 		= factoryVO.contextFactory;
		var constructorVO 	= factoryVO.constructorVO;
		
		for ( arg in constructorVO.arguments )
			result.push( factory.buildVO( arg ) );

		return result;
	}
	#end
}