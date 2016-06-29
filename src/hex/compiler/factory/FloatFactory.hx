package hex.compiler.factory;

import haxe.macro.Context;
import hex.ioc.vo.FactoryVO;
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
	
	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;

		var args : Array<Dynamic> 	= constructorVO.arguments;
		var number : Float 	= Math.NaN;

		if ( args != null && args.length > 0 ) 
		{
			number = Std.parseFloat( args[ 0 ] );
		}

		if ( !Math.isNaN( number ) && "" + number == args[0] )
		{
			constructorVO.result = number;
			
			if ( !constructorVO.isProperty )
			{
				var idVar = constructorVO.ID;
				factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $v { number }; } );
			}
		}
		else
		{
			Context.error( "Value is not a Float", constructorVO.filePosition );
		}
		
		return macro @:pos( constructorVO.filePosition ) { $v { number } };
	}
	#end
}