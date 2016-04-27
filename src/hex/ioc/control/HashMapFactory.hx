package hex.ioc.control;

import hex.ioc.vo.FactoryVO;
import hex.collection.HashMap;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.MapVO;
import hex.log.Logger;

/**
 * ...
 * @author Francis Bourre
 */
class HashMapFactory
{
	function new()
	{

	}

	static public function build( factoryVO : FactoryVO ) : Void
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;

		var map = new HashMap<Dynamic, Dynamic>();
		var args : Array<MapVO> = cast constructorVO.arguments;

		if ( args.length == 0 )
		{
			#if debug
			Logger.WARN( "HashMapFactory.build(" + args + ") returns an empty HashMap." );
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
					trace( "HashMapFactory.build() adds item with a 'null' key for '"  + item.value +"' value." );
				}
			}
		}

		constructorVO.result = map;

		if ( constructorVO.mapType != null )
		{
			factoryVO.contextFactory.getApplicationContext().getBasicInjector().mapToValue( HashMap, constructorVO.result, constructorVO.ID );
		}
	}
}