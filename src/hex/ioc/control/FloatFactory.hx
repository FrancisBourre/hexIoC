package hex.ioc.control;

import hex.ioc.vo.FactoryVO;
import hex.error.IllegalArgumentException;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class FloatFactory
{
	function new()
	{

	}
	
	static public function build( factoryVO : FactoryVO ) : Void
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;

		var args : Array<Dynamic> 	= constructorVO.arguments;
		var number : Float 	= Math.NaN;

		if ( args != null && args.length > 0 ) 
		{
			number = Std.parseFloat( args[ 0 ] );
		}

		if ( !Math.isNaN( number ) )
		{
			constructorVO.result = number;
			
			#if macro
			if ( !constructorVO.isProperty )
			{
				var idVar = constructorVO.argumentName != null ? constructorVO.argumentName : constructorVO.ID;
				factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $v { number }; } );
			}
			#end
		}
		else
		{
			throw new IllegalArgumentException( "FloatFactory.build(" + number + ") failed." );
		}
	}
}