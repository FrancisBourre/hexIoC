package hex.ioc.parser.xml.state.mock;

import hex.control.command.BasicCommand;
import hex.control.Request;

/**
 * ...
 * @author Francis Bourre
 */
class MockExitStateCommand extends BasicCommand
{
	public function execute( ?request : Request ) : Void 
	{
		( cast this.getOwner() ).commandWasCalled = true;
	}
}