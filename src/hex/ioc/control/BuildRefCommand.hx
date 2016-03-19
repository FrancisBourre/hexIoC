package hex.ioc.control;

import hex.ioc.vo.BuildHelperVO;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildRefCommand implements IBuildCommand
{
	public function new()
	{

	}

	public function execute( buildHelperVO : BuildHelperVO ) : Void
	{
		var constructorVO : ConstructorVO = buildHelperVO.constructorVO;

		var key : String = constructorVO.ref;

		if ( key.indexOf(".") != -1 ) 
		{
			key = Std.string( ( key.split( "." ) ).shift() );
		}

		if ( !( buildHelperVO.coreFactory.isRegisteredWithKey( key ) ) )
		{
			buildHelperVO.builderFactory.buildObject( key );
		}
		
		constructorVO.result = buildHelperVO.coreFactory.locate( key );

		if ( constructorVO.ref.indexOf(".") != -1 )
		{
			var args : Array<String> = constructorVO.ref.split( "." );
			args.shift();

			var tmp : Dynamic = buildHelperVO.coreFactory.fastEvalFromTarget( constructorVO.result, args.join( "." )  );
			var result : Dynamic = tmp;

			constructorVO.result = result;
		}
	}
}