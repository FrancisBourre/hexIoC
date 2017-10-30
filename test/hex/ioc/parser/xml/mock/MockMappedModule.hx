package hex.ioc.parser.xml.mock;

import hex.module.dependency.IRuntimeDependencies;
import hex.module.dependency.RuntimeDependencies;
import hex.module.Module;

/**
 * ...
 * @author Francis Bourre
 */
class MockMappedModule extends Module implements IMockMappedModule implements IAnotherMockMappedModule
{
	public function new() 
	{
		super();
	}
	
	public function doSomething() : Void 
	{
		
	}
	
	public function doSomethingElse() : Void
	{
		
	}
	
	#if debug
	override function _getRuntimeDependencies() : IRuntimeDependencies
	{
		return new RuntimeDependencies();
	}
	#end
}