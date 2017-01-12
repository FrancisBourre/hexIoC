package hex.ioc.control;

import hex.error.IllegalArgumentException;
import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;

/**
 * ...
 * @author Francis Bourre
 */
class FloatFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }
	
	static public function build( factoryVO : FactoryVO ) : Float
	{
		var result : Dynamic 	= Math.NaN;
		var constructorVO 		= factoryVO.constructorVO;
		var args 				= constructorVO.arguments;

		if ( args != null && args.length > 0 ) 
		{
			result = Std.parseFloat( args[ 0 ] );
		}

		if ( Math.isNaN( result ) )
		{
			throw new IllegalArgumentException( "FloatFactory.build(" + result + ") failed." );
		}
		
		return result;
	}
}