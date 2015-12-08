package hex.ioc.core;

import hex.collection.Locator;
import hex.collection.LocatorEvent;
import hex.event.IEvent;
import hex.module.IModule;

/**
 * ...
 * @author Francis Bourre
 */
class ModuleLocator extends Locator<String, IModule, LocatorEvent<String, IModule>>
{
	public function new() 
	{
		super();
	}
	
	override function _dispatchRegisterEvent( key : String, element : IModule ) : Void 
	{
		this._dispatcher.dispatchEvent( new LocatorEvent( LocatorEvent.REGISTER, this, key, element ) );
	}
	
	override function _dispatchUnregisterEvent( key : String ) : Void 
	{
		this._dispatcher.dispatchEvent( new LocatorEvent( LocatorEvent.UNREGISTER, this, key ) );
	}
}