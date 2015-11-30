package hex.ioc.control;

import hex.event.IEvent;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildRefCommand extends AbstractBuildCommand
{
	public function new() 
	{
		
	}
	
	override public function execute( ?e : IEvent ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;

		var key : String = constructorVO.ref;

		if ( key.indexOf(".") != -1 ) key = Std.string( ( key.split( "." ) ).shift() );

		if ( !( this._buildHelperVO.coreFactory.isRegisteredWithKey( key ) ) )
		{
			this._buildHelperVO.builderFactory.getConstructorVOLocator().buildObject( key );
		}
		
		constructorVO.result = this._buildHelperVO.coreFactory.locate( key );

		if ( constructorVO.ref.indexOf(".") != -1 )
		{
			var args : Array<String> = constructorVO.ref.split( "." );
			args.shift();

			var tmp : Dynamic = ObjectUtils.evalFromTarget( constructorVO.result, args.join( "." ), this._buildHelperVO.coreFactory );
			var result : Dynamic = tmp;

			constructorVO.result = result;
		}
	}
}