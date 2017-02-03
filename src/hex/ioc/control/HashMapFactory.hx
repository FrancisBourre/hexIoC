package hex.ioc.control;

import hex.collection.HashMap;
import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;
import hex.log.Logger;

/**
 * ...
 * @author Francis Bourre
 */
class HashMapFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }

	static public function build( factoryVO : FactoryVO ) : HashMap<Dynamic, Dynamic>
	{
		var constructorVO 	= factoryVO.constructorVO;
		var result 			= new HashMap<Dynamic, Dynamic>();
		var args 			= MapArgumentFactory.build( factoryVO );

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
					result.put( item.key, item.value );

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
						.mapClassNameToValue( mapType, result, constructorVO.ID );
				}
			}
		}

		return result;
	}
}