package hex.ioc.control;

import hex.ioc.di.MappingConfiguration;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.MapVO;

/**
 * ...
 * @author Francis Bourre
 */
class MappingConfigurationFactory
{
	function new()
	{

	}

	static public function build( factoryVO : FactoryVO ) : Void
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;

		var config = new MappingConfiguration();
		var args : Array<MapVO> = cast constructorVO.arguments;

		if ( args.length <= 0 )
		{
			trace( "MappingConfigurationFactory.build(" + args + ") returns an empty congiuration." );

		} else
		{
			for ( item in args )
			{
				if ( item.key != null )
				{
					config.addMapping( item.key, item.value, item.mapName );

				} else
				{
					trace( "MappingConfigurationFactory.build() adds item with a 'null' key for '"  + item.value +"' value." );
				}
			}
		}

		constructorVO.result = config;
	}
}