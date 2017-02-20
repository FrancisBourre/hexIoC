package hex.ioc.parser.xml.assembler.mock;

import hex.control.command.BasicCommand;
import hex.core.IApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class MockExitStateCommand extends BasicCommand
{
	static public var callCount : Int = 0;
	static public var lastInjecteContext : IApplicationContext;
	
	@Inject
	public var context : IApplicationContext;
	
	override public function execute() : Void
	{
		MockExitStateCommand.callCount++;
		MockExitStateCommand.lastInjecteContext = this.context;
	}
}