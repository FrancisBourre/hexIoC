package hex.ioc.control;

import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;

/**
 * ...
 * @author Francis Bourre
 */
class DynamicObjectFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }

	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		return {};
	}
}