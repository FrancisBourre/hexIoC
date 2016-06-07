package hex.compiler.factory;

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

	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var constructorVO = factoryVO.constructorVO;
		factoryVO.constructorVO.result = { };
		
		#if macro
		if ( !constructorVO.isProperty )
		{
			var idVar = constructorVO.ID;
			factoryVO.expressions.push( macro @:mergeBlock { var $idVar : Dynamic = $v { {} }; } );
		}
		#end
		
		return null;
	}
}