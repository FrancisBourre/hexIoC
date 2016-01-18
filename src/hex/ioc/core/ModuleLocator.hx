package hex.ioc.core;

import hex.collection.Locator;
import hex.collection.LocatorMessage;
import hex.ioc.core.BuilderFactory;
import hex.module.IModule;

/**
 * ...
 * @author Francis Bourre
 */
class ModuleLocator extends Locator<String, IModule>
{
	private var _builderFactory : BuilderFactory;

	public function new( builderFactory : BuilderFactory )
	{
		super();
		this._builderFactory = builderFactory;
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