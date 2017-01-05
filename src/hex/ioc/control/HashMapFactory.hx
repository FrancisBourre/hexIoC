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
		//build arguments
		MapArgumentFactory.build( factoryVO );
		
		var constructorVO = factoryVO.constructorVO;

		var map = new HashMap<Dynamic, Dynamic>();
		var args : Array<MapVO> = cast constructorVO.arguments;

		if ( args.length == 0 )
		{
			#if debug
			Logger.warn( "HashMapFactory.build(" + args + ") returns an empty HashMap." );
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
					//Remove whitespaces
					mapType = mapType.split( ' ' ).join( '' );
					
					factoryVO.contextFactory.getApplicationContext().getInjector()
						.mapClassNameToValue( mapType, map, constructorVO.ID );
				}
			}
		}

		constructorVO.result = map;
	}
}