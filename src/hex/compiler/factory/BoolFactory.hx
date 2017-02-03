package hex.compiler.factory;

import haxe.macro.Context;
import haxe.macro.Expr;
import hex.compiler.vo.FactoryVO;
import hex.error.PrivateConstructorException;

/**
 * ...
 * @author Francis Bourre
 */
class BoolFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }
	
	#if macro
	static public function build( factoryVO : FactoryVO ) : Expr
	{
		var result : Bool 		= false;
		
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		var args 				= constructorVO.arguments;
		
		var value = "";
		if ( args != null && args.length > 0 ) 
		{
			value = args[ 0 ];
		}
		
		if ( value == "true" )
		{
			result = true;
		}
		else if ( value == "false" )
		{
			result = false;
		}
		else
		{
			Context.error( "Value is not a Bool", constructorVO.filePosition );
		}
		
		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $v{ result }:
			macro @:pos( constructorVO.filePosition ) $v{ result };	
	}
	#end
}