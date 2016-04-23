package hex.ioc.locator;

import hex.collection.Locator;
import hex.collection.LocatorMessage;
import hex.ioc.core.IContextFactory;
import hex.module.IModule;

/**
 * ...
 * @author Francis Bourre
 */
class ModuleLocator extends Locator<String, IModule>
{
	var _contextFactory : IContextFactory;

	public function new( contextFactory : IContextFactory )
	{
		super();
		this._contextFactory = contextFactory;
	}
	
	public function callModuleInitialisation() 
	{
		var modules : Array<IModule> = this.values();
		for ( module in modules )
		{
			module.initialize();
		}
		
		this.clear();
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