package hex.ioc.control;

import hex.ioc.vo.BuildHelperVO;
import hex.error.Exception;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildFunctionCommand implements IBuildCommand
{
	public function new()
	{

	}

	public function execute( buildHelperVO : BuildHelperVO ) : Void
	{
		var constructorVO : ConstructorVO = buildHelperVO.constructorVO;

		var method : Dynamic;
		var msg : String;

		var args : Array<String> = constructorVO.arguments[ 0 ].split(".");
		var targetID : String = args[ 0 ];
		var path : String = args.slice( 1 ).join( "." );

		if ( !buildHelperVO.coreFactory.isRegisteredWithKey( targetID ) )
		{
			buildHelperVO.builderFactory.buildObject( targetID );
		}

		var target : Dynamic = buildHelperVO.coreFactory.locate( targetID );

		try
		{
			method = buildHelperVO.coreFactory.fastEvalFromTarget( target, path );

		} catch ( error : Dynamic )
		{
			msg = " " + this + ".execute() failed on " + target + " with id '" + targetID + "'. ";
			msg += path + " method can't be found.";
			throw new Exception( msg );
		}

		constructorVO.result = method;
	}
}