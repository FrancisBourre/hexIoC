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
		
		var result = factoryVO.coreFactory.locate( key );
		
		if ( constructorVO.ref.indexOf( "." ) != -1 )
		{
			var args = constructorVO.ref.split( "." );
			args.shift();
			constructorVO.result = factoryVO.coreFactory.fastEvalFromTarget( result, args.join( "." )  );
		}
		else 
		{
			constructorVO.result = result;
		}
	}
}