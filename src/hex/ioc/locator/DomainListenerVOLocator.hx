package hex.ioc.locator;

import hex.collection.Locator;
import hex.collection.LocatorMessage;
import hex.ioc.vo.DomainListenerVO;

/**
 * ...
 * @author Francis Bourre
 */
class DomainListenerVOLocator extends Locator<String, DomainListenerVO>
{
	public function new()
	{
		super();
	}
	
	override function _dispatchRegisterEvent( key : String, element : DomainListenerVO ) : Void 
	{
		this._dispatcher.dispatch( LocatorMessage.REGISTER, [key, element] );
	}
	
	override function _dispatchUnregisterEvent( key : String ) : Void 
	{
		this._dispatcher.dispatch( LocatorMessage.UNREGISTER, [key] );
	}
}