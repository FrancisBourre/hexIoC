package hex.ioc.control;

import hex.ioc.vo.BuildHelperVO;
import hex.config.stateful.ServiceLocator;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.ServiceLocatorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildServiceLocatorCommand implements IBuildCommand
{
	public function new()
	{

	}

	public function execute( buildHelperVO : BuildHelperVO ) : Void
	{
		var constructorVO : ConstructorVO = buildHelperVO.constructorVO;

		var serviceLocator = new ServiceLocator();
		var args : Array<ServiceLocatorVO> = cast constructorVO.arguments;

		if ( args.length <= 0 )
		{
			trace( this + ".execute(" + args + ") returns an empty ServiceConfig." );

		} else
		{
			for ( item in args )
			{
				if ( item.key != null )
				{
					serviceLocator.addService( item.key, item.value, item.mapName );

				} else
				{
					trace( this + ".execute() adds item with a 'null' key for '"  + item.value +"' value." );
				}
			}
		}

		constructorVO.result = serviceLocator;
	}
}