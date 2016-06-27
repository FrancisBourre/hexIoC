package hex.compiler.factory;

import haxe.macro.Context;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;

/**
 * ...
 * @author Francis Bourre
 */
class ReferenceFactory
{
	function new() 
	{
		
	}
	
	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;

		var key : String = constructorVO.ref;

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
			if ( !constructorVO.isProperty )
			{
				var p = macro @:pos( constructorVO.filePosition ) $p { constructorVO.ref.split(".") };
				var idVar = constructorVO.ID;
				factoryVO.expressions.push( macro @:pos( constructorVO.filePosition ) @:mergeBlock { var $idVar = $p; } );
			}
			
			var e = macro @:pos( constructorVO.filePosition ) $p { constructorVO.ref.split(".") };
			return e;
		}
		else 
		{
			if ( !constructorVO.isProperty )
			{
				var idVar = constructorVO.ID;
				var extVar = macro @:pos( constructorVO.filePosition ) $i{ key };
				factoryVO.expressions.push( macro @:pos( constructorVO.filePosition ) @:mergeBlock { var $idVar = $extVar; } );
				
			}
			
			return macro @:pos( constructorVO.filePosition ) $i{ key };
		}
	}
	#end
}