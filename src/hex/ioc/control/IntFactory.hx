package hex.ioc.control;

import hex.ioc.vo.FactoryVO;
import hex.error.IllegalArgumentException;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class IntFactory
{
	function new()
	{

	}
	
	static public function build( factoryVO : FactoryVO ) : Void
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;
		var args 	: Array<Dynamic> 	= constructorVO.arguments;
		var number 	: Int = 0;

		if ( args != null && args.length > 0 ) 
		{
			number = Std.parseInt( Std.string( args[0] ) );
		}
		else
		{
			throw new IllegalArgumentException( "IntFactory.build(" + ( args != null && args.length > 0 ? args[0] : "" ) + ") failed." );
		}

		#if js
		if ( number == null )
		#else
		if ( "" + number != args[0] )
		#end
		{
			throw new IllegalArgumentException( "IntFactory.build(" + number + ") failed." );
		}
		else
		{
			constructorVO.result = number;

			#if macro
			if ( !constructorVO.isProperty )
			{
				var idVar = constructorVO.ID;
				factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $v { number }; } );
			}
			#end
		}
	}
}