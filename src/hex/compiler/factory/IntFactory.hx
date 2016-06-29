package hex.compiler.factory;

import haxe.macro.Context;
import hex.ioc.vo.FactoryVO;
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
	
	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var constructorVO : ConstructorVO 	= factoryVO.constructorVO;
		var args 	: Array<Dynamic> 		= constructorVO.arguments;
		var number 	: Int 					= 0;

		if ( args != null && args.length > 0 ) 
		{
			number = Std.parseInt( Std.string( args[0] ) );
		}
		else
		{
			Context.error( "IntFactory.build(" + ( args != null && args.length > 0 ? args[0] : "" ) + ") failed.", constructorVO.filePosition );
		}

		if ( "" + number != args[0] )
		{
			Context.error( "Value is not an Int", constructorVO.filePosition );
		}
		else
		{
			constructorVO.result = number;

			if ( !constructorVO.isProperty )
			{
				var idVar = constructorVO.ID;
				factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $v { number }; } );
			}
		};
		
		return macro @:pos( constructorVO.filePosition ) { $v { number } };
	}
	#end
}