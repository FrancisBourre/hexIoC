package hex.compiler.factory;

import haxe.macro.Expr;
import hex.ioc.vo.FactoryVO;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class StaticVariableFactory
{
	function new()
	{

	}

	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var constructorVO = factoryVO.constructorVO;
		var e : Expr = MacroUtil.getStaticVariable( constructorVO.staticRef, constructorVO.filePosition );
		
		if ( !constructorVO.isProperty )
		{
			var idVar = constructorVO.ID;
			factoryVO.expressions.push( macro @:pos( constructorVO.filePosition ) @:mergeBlock { var $idVar = $e; } );
		}
		
		return e;
	}
	#end
}