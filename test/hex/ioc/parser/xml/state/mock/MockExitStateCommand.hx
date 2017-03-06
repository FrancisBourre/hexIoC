package hex.ioc.parser.xml.state.mock;

import hex.control.command.BasicCommand;

/**
 * ...
 * @author Francis Bourre
 */
class MockExitStateCommand extends BasicCommand
{
	override public function execute() : Void
	{
		( cast this.getOwner() ).commandWasCalled = true;
	}
}