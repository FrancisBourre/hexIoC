package hex.compiler.factory;

import haxe.macro.Context;
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
	
	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var result 	: Int 		= 0;
		
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		var args 				= constructorVO.arguments;
		

		if ( args != null && args.length > 0 ) 
		{
			var s = Std.string( args[ 0 ] );
			result = Std.parseInt( s );
		}
		else
		{
			Context.error( "Invalid arguments.", constructorVO.filePosition );
		}
		
		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $v{ result }:
			macro @:pos( constructorVO.filePosition ) $v{ result };	
	}
	#end
}