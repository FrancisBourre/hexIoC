package hex.ioc.control;

import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;
import hex.util.ClassUtil;

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
	
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{ 
		return ClassUtil.getStaticVariableReference( factoryVO.constructorVO.staticRef );
	}
}