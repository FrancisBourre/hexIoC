package hex.ioc.control;

import hex.error.IllegalArgumentException;
import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;

/**
 * ...
 * @author Francis Bourre
 */
class IntFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }
	
	static public function build( factoryVO : FactoryVO ) : Int
	{
		var constructorVO 	= factoryVO.constructorVO;
		var args 			= constructorVO.arguments;
		var result 	: Int 	= 0;

		if ( args != null && args.length > 0 ) 
		{
			result = Std.parseInt( Std.string( args[ 0 ] ) );
		}
		else
		{
			throw new IllegalArgumentException( "IntFactory.build(" + ( args != null && args.length > 0 ? args[0] : "" ) + ") failed." );
		}

		#if js
		if ( result == null )
		#else
		if ( "" + result != args[ 0 ] && '0x' + StringTools.hex( result, 6 ) != args[ 0 ] )
		#end
		{
			throw new IllegalArgumentException( "IntFactory.build(" + result + ") failed." );
		}
		
		return result;
	}
}