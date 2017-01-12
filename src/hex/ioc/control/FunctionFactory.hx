package hex.ioc.control;

import hex.error.Exception;
import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;

/**
 * ...
 * @author Francis Bourre
 */
class FunctionFactory
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
		var args 				= constructorVO.arguments[ 0 ].split(".");
		var targetID 			= args[ 0 ];
		var path 				= args.slice( 1 ).join( "." );

		if ( !factoryVO.coreFactory.isRegisteredWithKey( targetID ) )
		{
			factoryVO.contextFactory.buildObject( targetID );
		}

		var target : Dynamic = factoryVO.coreFactory.locate( targetID );

		try
		{
			result = factoryVO.coreFactory.fastEvalFromTarget( target, path );

		} catch ( error : Dynamic )
		{
			var msg = "FunctionFactory.build() failed on " + target + " with id '" + targetID + "'. ";
			msg += path + " method can't be found.";
			throw new Exception( msg );
		}

		return result;
	}
}