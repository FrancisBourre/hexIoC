package hex.ioc.parser.xml.state.mock;

import hex.control.command.BasicCommand;
import hex.control.Request;

/**
 * ...
 * @author Francis Bourre
 */
@:rtti
class MockExitStateCommand extends BasicCommand
{
	override public function execute( ?request : Request ) : Void 
	{
		( cast this.getOwner() ).commandWasCalled = true;
	}
}