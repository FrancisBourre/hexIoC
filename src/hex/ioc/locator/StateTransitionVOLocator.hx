package hex.ioc.locator;

import hex.collection.Locator;
import hex.collection.LocatorMessage;
import hex.ioc.vo.StateTransitionVO;
import hex.state.StateUnmapper;

/**
 * ...
 * @author Francis Bourre
 */
class StateTransitionVOLocator extends Locator<String, StateTransitionVO>
{
	public function new()
	{
		super();
	}
	
	override public function release() : Void
	{
		StateUnmapper.release();
		super.release();
	}
	
	override function _dispatchRegisterEvent( key : String, element : StateTransitionVO ) : Void 
	{
		this._dispatcher.dispatch( LocatorMessage.REGISTER, [ key, element ] );
	}
	
	override function _dispatchUnregisterEvent( key : String ) : Void 
	{
		this._dispatcher.dispatch( LocatorMessage.UNREGISTER, [ key ] );
	}
}