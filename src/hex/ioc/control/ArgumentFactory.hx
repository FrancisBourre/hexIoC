package hex.ioc.control;

import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;

/**
 * ...
 * @author Francis Bourre
 */
class ArgumentFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }

	static public function build( factoryVO : FactoryVO ) : Array<Dynamic>
	{
		var factory 		= factoryVO.contextFactory;
		var cons 			= factoryVO.constructorVO;
		var result 			= [];
		
		for ( arg in cons.arguments )
			result.push( factory.buildVO( arg ) );

		return result;
	}
}