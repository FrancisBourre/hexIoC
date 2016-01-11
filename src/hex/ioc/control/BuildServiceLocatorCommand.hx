package hex.ioc.control;

import hex.config.stateful.ServiceLocator;
import hex.control.Request;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.ServiceLocatorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildServiceLocatorCommand extends AbstractBuildCommand
{
	override public function execute( ?request : Request ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;

		var serviceLocator : ServiceLocator = new ServiceLocator();
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