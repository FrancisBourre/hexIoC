package hex.ioc.locator;

import hex.collection.Locator;
import hex.collection.LocatorMessage;
import hex.ioc.vo.MethodCallVO;

/**
 * ...
 * @author Francis Bourre
 */
class MethodCallVOLocator extends Locator<String, MethodCallVO>
{
	public function new()
	{
		super();
	}
	
	override function _dispatchRegisterEvent( key : String, element : MethodCallVO ) : Void 
	{
		this._dispatcher.dispatch( LocatorMessage.REGISTER, [ key, element ] );
	}
	
	override function _dispatchUnregisterEvent( key : String ) : Void 
	{
		this._dispatcher.dispatch( LocatorMessage.UNREGISTER, [ key ] );
	}
}