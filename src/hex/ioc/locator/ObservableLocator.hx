package hex.ioc.locator;

import hex.collection.Locator;
import hex.collection.LocatorMessage;
import hex.event.IObservable;
import hex.ioc.core.IContextFactory;

/**
 * ...
 * @author Francis Bourre
 */
class ObservableLocator extends Locator<String, Bool>
{
	var _contextFactory : IContextFactory;

	public function new( contextFactory : IContextFactory )
	{
		super();
		this._contextFactory = contextFactory;
	}
	
	override function _dispatchRegisterEvent( key : String, element : Bool ) : Void 
	{
		this._dispatcher.dispatch( LocatorMessage.REGISTER, [ key, element ] );
	}
	
	override function _dispatchUnregisterEvent( key : String ) : Void 
	{
		this._dispatcher.dispatch( LocatorMessage.UNREGISTER, [ key ] );
	}
}