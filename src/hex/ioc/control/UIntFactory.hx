package hex.ioc.control;

import hex.ioc.vo.FactoryVO;
import hex.error.IllegalArgumentException;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class UIntFactory
{
	function new()
	{

	}
	
	static public function build( factoryVO : FactoryVO ) : Void
	{
		var constructorVO : ConstructorVO 	= factoryVO.constructorVO;

		var args 	: Array<Dynamic> 		= constructorVO.arguments;
		var number 	: UInt 					= 0;

		if ( args != null && args.length > 0 ) 
		{
			number = Std.parseInt( Std.string( args[0] ) );
		}
		else
		{
			throw new IllegalArgumentException( "UIntFactory.build(" + ( args != null && args.length > 0 ? args[0] : "" ) + ") failed." );
		}
		
		#if js
		if ( number == null || number < 0 )
		#else
		if ( "" + number != args[0] && number >=0 )
		#end
		{
			throw new IllegalArgumentException( "UIntFactory.build(" + number + ") failed." );
		}
		else
		{
			constructorVO.result = number;
		}
	}
}