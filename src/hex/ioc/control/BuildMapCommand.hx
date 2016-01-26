package hex.ioc.control;

import hex.collection.HashMap;
import hex.control.Request;
import hex.ioc.control.AbstractBuildCommand;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.MapVO;
import hex.log.Logger;

/**
 * ...
 * @author Francis Bourre
 */
class BuildMapCommand extends AbstractBuildCommand
{
	override public function execute( ?request : Request ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;

		var map = new HashMap<Dynamic, Dynamic>();
		var args : Array<MapVO> = cast constructorVO.arguments;

		if ( args.length == 0 )
		{
			#if debug
			Logger.WARN( this + ".execute(" + args + ") returns an empty HashMap." );
			#end

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
			this._buildHelperVO.builderFactory.getApplicationContext().getBasicInjector().mapToValue( HashMap, constructorVO.result, constructorVO.ID );
		}
	}
}