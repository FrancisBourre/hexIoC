package hex.ioc.core;

import hex.collection.Locator;
import hex.collection.LocatorMessage;
import hex.module.IModule;

/**
 * ...
 * @author Francis Bourre
 */
class ModuleLocator extends Locator<String, IModule>
{
	public function new() 
	{
		super();
	}
	
	override function _dispatchRegisterEvent( key : String, element : IModule ) : Void 
	{
		this._dispatcher.dispatch( LocatorMessage.REGISTER, [ key, element ] );
	}
	
	override function _dispatchUnregisterEvent( key : String ) : Void 
	{
		this._dispatcher.dispatch( LocatorMessage.UNREGISTER, [ key ] );
	}
}