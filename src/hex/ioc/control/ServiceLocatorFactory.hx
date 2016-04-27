package hex.ioc.control;

import hex.ioc.vo.FactoryVO;
import hex.config.stateful.ServiceLocator;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.ServiceLocatorVO;

/**
 * ...
 * @author Francis Bourre
 */
class ServiceLocatorFactory
{
	public function new()
	{

	}

	static public function build( factoryVO : FactoryVO ) : Void
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;

		var serviceLocator = new ServiceLocator();
		var args : Array<ServiceLocatorVO> = cast constructorVO.arguments;

		if ( args.length <= 0 )
		{
			trace( "ServiceLocatorFactory.build(" + args + ") returns an empty ServiceConfig." );

		} else
		{
			for ( item in args )
			{
				if ( item.key != null )
				{
					serviceLocator.addService( item.key, item.value, item.mapName );

				} else
				{
					trace( "ServiceLocatorFactory.build() adds item with a 'null' key for '"  + item.value +"' value." );
				}
			}
		}

		constructorVO.result = serviceLocator;
	}
}