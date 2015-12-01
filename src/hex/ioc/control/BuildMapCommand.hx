package hex.ioc.control;

import hex.collection.HashMap;
import hex.event.IEvent;
import hex.ioc.control.AbstractBuildCommand;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.MapVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildMapCommand extends AbstractBuildCommand
{
	public function new() 
	{
		
	}
	
	override public function execute( ?e : IEvent ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;

		var map : HashMap = new HashMap();
		var args : Array<MapVO> = constructorVO.arguments;

		if ( args.length == 0 )
		{
			trace( this + ".execute(" + args + ") returns an empty Dictionary." );

		} else
		{
			for ( item in args )
			{
				if ( item.key != null )
				{
					map.put( item.key, item.value );

				} else
				{
					trace( this + ".execute() adds item with a 'null' key for '"  + item.value +"' value." );
				}
			}
		}

		constructorVO.result = map;

		if ( constructorVO.mapType != null )
		{
			this._buildHelperVO.builderFactory.getApplicationContext().getInjector().mapToValue( Dictionary, constructorVO.result, constructorVO.ID );
		}
	}
}