package hex.ioc.parser.xml.assembler.mock;

import hex.module.dependency.IRuntimeDependencies;
import hex.module.dependency.RuntimeDependencies;
import hex.module.Module;

/**
 * ...
 * @author Francis Bourre
 */
class MockModule extends Module
{
	public function new() 
	{
		super();
	}
	
	override function _getRuntimeDependencies() : IRuntimeDependencies 
	{
		return new RuntimeDependencies();
	}
}