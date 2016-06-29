package hex.compiler.factory;

import haxe.macro.Context;
import hex.ioc.vo.FactoryVO;
import hex.error.IllegalArgumentException;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BoolFactory
{
	function new()
	{

	}
	
	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;

		var value : String 	= "";
		var args 			= constructorVO.arguments;

		if ( args != null && args.length > 0 ) 
		{
			value = args[0];
		}
		
		if ( value == "true" )
		{
			constructorVO.result = true;
		}
		else if ( value == "false" )
		{
			constructorVO.result = false;
		}
		else
		{
			Context.error( "Value is not a Bool", constructorVO.filePosition );
		}
		
		if ( !constructorVO.isProperty )
		{
			var idVar = constructorVO.ID;
			factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $v { constructorVO.result }; } );
		}
		
		return macro @:pos( constructorVO.filePosition ) { $v { constructorVO.result } };
	}
	#end
}