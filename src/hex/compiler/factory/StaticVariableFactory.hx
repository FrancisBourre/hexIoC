package hex.compiler.factory;

import haxe.macro.Expr;
import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class StaticVariableFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }

	#if macro
	static public function build( factoryVO : FactoryVO ) : Expr
	{
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		
		//Building result
		var result	= MacroUtil.getStaticVariable( constructorVO.staticRef, constructorVO.filePosition );
		
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $result:
			macro @:pos( constructorVO.filePosition ) $result;
	}
	#end
}