package hex.ioc.control;

import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;

/**
 * ...
 * @author Francis Bourre
 */
class ReferenceFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }
	
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var result : Dynamic 	= null;
		var constructorVO 		= factoryVO.constructorVO;
		var key 				= constructorVO.ref;

		if ( key.indexOf(".") != -1 )
		{
			key = Std.string( ( key.split( "." ) ).shift() );
		}

		if ( !( factoryVO.coreFactory.isRegisteredWithKey( key ) ) )
		{
			factoryVO.contextFactory.buildObject( key );
		}
		
		if ( constructorVO.ref.indexOf( "." ) != -1 )
		{
			var args = constructorVO.ref.split( "." );
			args.shift();
			result = factoryVO.coreFactory.fastEvalFromTarget( factoryVO.coreFactory.locate( key ), args.join( "." )  );
		}
		else 
		{
			result = factoryVO.coreFactory.locate( key );
		}
		
		return result; 
	}
}