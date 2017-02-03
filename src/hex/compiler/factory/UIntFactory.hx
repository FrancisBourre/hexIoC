package hex.compiler.factory;

import haxe.macro.Context;
import hex.compiler.vo.FactoryVO;
import hex.error.PrivateConstructorException;

/**
 * ...
 * @author Francis Bourre
 */
class UIntFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }
	
	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var result 	: UInt 		= 0;
		
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		var args 				= constructorVO.arguments;
		
		if ( args != null && args.length > 0 ) 
		{
			result = Std.parseInt( Std.string( args[ 0 ] ) );
		}
		else
		{
			Context.error( "Invalid arguments.", constructorVO.filePosition );
		}

		if ( "" + result != args[ 0 ] && result >= 0 )
		{
			Context.error( "Value is not a UInt", constructorVO.filePosition );
		}

		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $v{ result }:
			macro @:pos( constructorVO.filePosition ) $v{ result };	
	}
	#end
}