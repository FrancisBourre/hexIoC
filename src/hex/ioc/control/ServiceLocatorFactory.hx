package hex.ioc.control;

import hex.config.stateful.ServiceLocator;
import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;

/**
 * ...
 * @author Francis Bourre
 */
class ServiceLocatorFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }

	static public function build( factoryVO : FactoryVO ) : ServiceLocator
	{
		var result = new ServiceLocator();
		var args = MapArgumentFactory.build( factoryVO );

		if ( args.length == 0 )
		{
			trace( "ServiceLocatorFactory.build(" + args + ") returns an empty ServiceConfig." );

		} else
		{
			for ( item in args )
			{
				if ( item.key != null )
				{
					result.addService( item.key, item.value, item.mapName );

				} else
				{
					trace( "ServiceLocatorFactory.build() adds item with a 'null' key for '"  + item.value +"' value." );
				}
			}
		}

		return result;
	}
}