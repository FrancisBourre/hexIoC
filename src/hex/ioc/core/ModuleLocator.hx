package hex.ioc.core;

import hex.collection.Locator;
import hex.event.IEvent;
import hex.module.IModule;

/**
 * ...
 * @author Francis Bourre
 */
class ModuleLocator extends Locator<String, IModule, IEvent>
{
	public function new() 
	{
		super();
	}
}