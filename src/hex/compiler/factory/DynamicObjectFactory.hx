package hex.compiler.factory;

import haxe.macro.Expr;
import hex.compiler.vo.FactoryVO;
import hex.error.PrivateConstructorException;

/**
 * ...
 * @author Francis Bourre
 */
class DynamicObjectFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }

	#if macro
	static public function build( factoryVO : FactoryVO ) : Expr
	{
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		
		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar : Dynamic = {}:
			macro @:pos( constructorVO.filePosition ) {};
	}
	#end
}