package hex.compiler.factory;

import haxe.macro.Expr;
import hex.compiler.vo.FactoryVO;
import hex.error.PrivateConstructorException;

/**
 * ...
 * @author Francis Bourre
 */
class ReferenceFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }
	
	#if macro
	static public function build( factoryVO : FactoryVO ) : Expr
	{
		var result : Expr 	= null;
		var constructorVO 	= factoryVO.constructorVO;
		var idVar 			= constructorVO.ID;
		var key 			= constructorVO.ref;

		if ( key.indexOf( "." ) != -1 )
		{
			key = Std.string( ( key.split( "." ) ).shift() );
		}

		if ( !( factoryVO.coreFactory.isRegisteredWithKey( key ) ) )
		{
			factoryVO.contextFactory.buildObject( key );
		}
		
		if ( constructorVO.ref.indexOf( "." ) != -1 )
		{
			result = macro @:pos( constructorVO.filePosition ) $p { constructorVO.ref.split( '.' ) };
		}
		else 
		{
			result = macro @:pos( constructorVO.filePosition ) $i{ key };
		}
		
		//Building result
		return constructorVO.shouldAssign ?
			macro var $idVar = $v{ result }:
			macro $result;
	}
	#end
}