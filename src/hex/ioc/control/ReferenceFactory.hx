package hex.ioc.control;

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
	
	static public function build( factoryVO : FactoryVO ) : Void
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;

		var key : String = constructorVO.ref;

		if ( key.indexOf(".") != -1 )
		{
			key = Std.string( ( key.split( "." ) ).shift() );
		}

		if ( !( factoryVO.coreFactory.isRegisteredWithKey( key ) ) )
		{
			factoryVO.contextFactory.buildObject( key );
		}

		#if macro
		if ( !constructorVO.isProperty )
		{
			var idVar = constructorVO.argumentName != null ? constructorVO.argumentName : constructorVO.ID;
			var extVar = macro $i{ constructorVO.ref };
			factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $extVar; } );
		}
		#end
		
		constructorVO.result = factoryVO.coreFactory.locate( key );

		if ( constructorVO.ref.indexOf( "." ) != -1 )
		{
			var args : Array<String> = constructorVO.ref.split( "." );
			args.shift();
			constructorVO.result = factoryVO.coreFactory.fastEvalFromTarget( constructorVO.result, args.join( "." )  );
		}
	}
}