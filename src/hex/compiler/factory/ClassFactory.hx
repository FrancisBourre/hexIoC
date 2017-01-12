package hex.compiler.factory;

import haxe.macro.Expr;
import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ClassFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }
	
	#if macro
	static public function build( factoryVO : FactoryVO ) : Expr
	{
		var qualifiedClassName 	= "";
		
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		var args 				= constructorVO.arguments;
		
		var args = constructorVO.arguments;
		if ( args != null && args.length > 0 )
		{
			qualifiedClassName = "" + args[ 0 ];
		}

		//TODO correct file position. seems there's a bug with file inclusion
		var tp = MacroUtil.getPack( qualifiedClassName, constructorVO.filePosition );

		
		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $p{ tp }:
			macro @:pos( constructorVO.filePosition ) $p{ tp };	
	}
	#end
}