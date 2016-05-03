package hex.ioc.control;

import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class NullFactory
{
	function new()
	{

	}
	
	static public function build( factoryVO : FactoryVO ) : Void
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;
		constructorVO.result = null;
		
		#if macro
		if ( !constructorVO.isProperty )
		{
			var idVar = constructorVO.argumentName != null ? constructorVO.argumentName : constructorVO.ID;
			factoryVO.expressions.push( macro @:mergeBlock { var $idVar = null; } );
		}
		#end
	}
}