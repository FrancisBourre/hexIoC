package hex.ioc.parser.xml.assembler.mock;

import hex.control.Request;
import hex.control.command.BasicCommand;
import hex.ioc.assembler.AbstractApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class MockExitStateCommand extends BasicCommand
{
	static public var callCount : Int = 0;
	static public var lastInjecteContext : AbstractApplicationContext;
	
	@Inject
	public var context : AbstractApplicationContext;
	
	public function execute( ?request : Request ) : Void 
	{
		MockExitStateCommand.callCount++;
		MockExitStateCommand.lastInjecteContext = this.context;
	}
}