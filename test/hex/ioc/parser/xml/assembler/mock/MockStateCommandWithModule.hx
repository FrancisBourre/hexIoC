package hex.ioc.parser.xml.assembler.mock;

import hex.control.command.BasicCommand;
import hex.module.IModule;

/**
 * ...
 * @author Francis Bourre
 */
class MockStateCommandWithModule extends BasicCommand
{
	static public var callCount : Int = 0;
	static public var lastInjectedModule : IModule;
	
	@Inject
	public var module : IModule;
	
	override public function execute() : Void
	{
		MockStateCommandWithModule.callCount++;
		MockStateCommandWithModule.lastInjectedModule = this.module;
	}
}