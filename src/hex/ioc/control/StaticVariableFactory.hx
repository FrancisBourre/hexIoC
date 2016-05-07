package hex.ioc.control;

import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.util.ClassUtil;

/**
 * ...
 * @author Francis Bourre
 */
class StaticVariableFactory
{
	function new()
	{

	}

	static public function build( factoryVO : FactoryVO ) : Void
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;
		constructorVO.result = ClassUtil.getStaticVariableReference( constructorVO.staticRef );
	}
}