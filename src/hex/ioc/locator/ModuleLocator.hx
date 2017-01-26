package hex.ioc.locator;

import hex.collection.Locator;
import hex.collection.LocatorMessage;
import hex.module.IModule;

/**
 * ...
 * @author Francis Bourre
 */
#if flash
class ModuleLocator extends Locator<String, Dynamic>
#else
class ModuleLocator extends Locator<String, IModule>
#end
{
	public function new()
	{
		super();
	}
	
	#if flash
	override function _dispatchRegisterEvent( key : String, element : Dynamic ) : Void 
	#else
	override function _dispatchRegisterEvent( key : String, element : IModule ) : Void 
	#end
	{
		this._dispatcher.dispatch( LocatorMessage.REGISTER, [ key, element ] );
	}
	
	override function _dispatchUnregisterEvent( key : String ) : Void 
	{
		this._dispatcher.dispatch( LocatorMessage.UNREGISTER, [ key ] );
	}
}