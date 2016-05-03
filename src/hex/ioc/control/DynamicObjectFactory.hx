package hex.ioc.control;

import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class DynamicObjectFactory
{
	function new()
	{

	}

	static public function build( factoryVO : FactoryVO ) : Void
	{
		var constructorVO = factoryVO.constructorVO;
		factoryVO.constructorVO.result = { };
		
		#if macro
		if ( !constructorVO.isProperty )
		{
			var idVar = constructorVO.argumentName != null ? constructorVO.argumentName : constructorVO.ID;
			factoryVO.expressions.push( macro @:mergeBlock { var $idVar : Dynamic = $v { {} }; } );
		}
		#end
	}
}