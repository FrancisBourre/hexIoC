package hex.ioc.control;

import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;

/**
 * ...
 * @author Francis Bourre
 */
class ArrayFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }

	
	static public function build( factoryVO : FactoryVO ) : Array<Dynamic>
	{
		var constructorVO 		= factoryVO.constructorVO;
		var result 				= [];
		var args 				= ArgumentFactory.build( factoryVO );

		if ( args != null )
		{
			result = args.copy();
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
		
		return result;
	}
}