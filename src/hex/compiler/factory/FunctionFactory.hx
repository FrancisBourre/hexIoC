package hex.compiler.factory;

import haxe.macro.Expr;
import hex.error.Exception;
import hex.error.PrivateConstructorException;
import hex.ioc.vo.ConstructorVO;
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

	static public function build( factoryVO : FactoryVO ) : Expr
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;

		var method : Dynamic;
		var msg : String;

		var args : Array<String> = constructorVO.arguments[ 0 ].split(".");
		var targetID : String = args[ 0 ];
		var path : String = args.slice( 1 ).join( "." );

		if ( !factoryVO.coreFactory.isRegisteredWithKey( targetID ) )
		{
			factoryVO.contextFactory.buildObject( targetID );
		}

		var target : Dynamic = factoryVO.coreFactory.locate( targetID );

		try
		{
			method = factoryVO.coreFactory.fastEvalFromTarget( target, path );

		} catch ( error : Dynamic )
		{
			msg = "FunctionFactory.build() failed on " + target + " with id '" + targetID + "'. ";
			msg += path + " method can't be found.";
			throw new Exception( msg );
		}

		constructorVO.result = method;
		
		return null;
	}
}