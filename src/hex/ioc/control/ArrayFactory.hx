package hex.ioc.control;

import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class ArrayFactory
{
	function new()
	{

	}
	
	static public function build( factoryVO : FactoryVO ) : Void
	{
		//build arguments
		ArgumentFactory.build( factoryVO );
		
		var constructorVO = factoryVO.constructorVO;

		var array : Array<Dynamic> = [];
		var args : Array<Dynamic> = constructorVO.arguments;

		if ( args != null )
		{
			array = args.copy();
		}

		constructorVO.result = array;
		
		if ( constructorVO.mapTypes != null )
		{
			var mapTypes = constructorVO.mapTypes;
			for ( mapType in mapTypes )
			{
				//Remove whitespaces
				mapType = mapType.split( ' ' ).join( '' );
					
				factoryVO.contextFactory.getApplicationContext().getInjector()
					.mapClassNameToValue( mapType, constructorVO.result, constructorVO.ID );
			}
		}
	}
}