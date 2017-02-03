package hex.compiler.factory;

import hex.compiler.vo.FactoryVO;
import hex.error.PrivateConstructorException;

/**
 * ...
 * @author Francis Bourre
 */
class NullFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }
	
	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		
		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = null:
			macro @:pos( constructorVO.filePosition ) null;
	}
	#end
}