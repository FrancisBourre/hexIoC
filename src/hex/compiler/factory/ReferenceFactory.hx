package hex.compiler.factory;

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
		
		//var result = factoryVO.coreFactory.locate( key );
		
		if ( constructorVO.ref.indexOf( "." ) != -1 )
		{
			/*var args : Array<String> = constructorVO.ref.split( "." );
			args.shift();
			constructorVO.result = factoryVO.coreFactory.fastEvalFromTarget( result, args.join( "." )  );*/
			
			if ( !constructorVO.isProperty )
			{
				var p = macro $p { constructorVO.ref.split(".") };
				var idVar = constructorVO.ID;
				factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $p; } );
			}
			
			return macro $p { constructorVO.ref.split(".") };
		}
		else 
		{
			//constructorVO.result = result;
			
			if ( !constructorVO.isProperty )
			{
				var idVar = constructorVO.ID;
				var extVar = macro $i{ key };
				factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $extVar; } );
				
			}
			
			return macro $i{ key };
		}
	}
	#end
}