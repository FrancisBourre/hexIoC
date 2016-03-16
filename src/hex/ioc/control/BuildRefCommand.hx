package hex.ioc.control;

import hex.control.Request;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildRefCommand extends AbstractBuildCommand
{
	override public function execute( ?request : Request ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;

		var key : String = constructorVO.ref;

		if ( key.indexOf(".") != -1 ) 
		{
			key = Std.string( ( key.split( "." ) ).shift() );
		}

		if ( !( this._buildHelperVO.coreFactory.isRegisteredWithKey( key ) ) )
		{
			this._buildHelperVO.builderFactory.buildObject( key );
		}
		
		constructorVO.result = this._buildHelperVO.coreFactory.locate( key );

		if ( constructorVO.ref.indexOf(".") != -1 )
		{
			var args : Array<String> = constructorVO.ref.split( "." );
			args.shift();

			var tmp : Dynamic = this._buildHelperVO.coreFactory.fastEvalFromTarget( constructorVO.result, args.join( "." )  );
			var result : Dynamic = tmp;

			constructorVO.result = result;
		}
	}
}