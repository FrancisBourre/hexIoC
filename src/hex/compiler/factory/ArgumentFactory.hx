package hex.compiler.factory;

import haxe.macro.Expr;
import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;

/**
 * ...
 * @author Francis Bourre
 */
class ArgumentFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }

	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var factory 		= factoryVO.contextFactory;
		var cons 			= factoryVO.constructorVO;
		var args 			= [];
		
		var arguments 		= cons.arguments;
		var l : Int = arguments.length;
		for ( i in 0...l )
			args.push( factory.buildVO( arguments[ i ] ) );

		return args;
	}
	#end
}