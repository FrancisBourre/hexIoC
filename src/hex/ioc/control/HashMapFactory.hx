package hex.ioc.control;

import hex.collection.HashMap;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
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
			
			if ( constructorVO.mapTypes != null )
			{
				var mapTypes = constructorVO.mapTypes;
				for ( mapType in mapTypes )
				{
					var classToMap : Class<Dynamic> = Type.resolveClass( mapType );
					factoryVO.contextFactory.getApplicationContext().getInjector().mapToValue( classToMap, map, constructorVO.ID );
				}
			}
		}

		constructorVO.result = map;
	}
}