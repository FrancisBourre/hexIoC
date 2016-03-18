package hex.ioc.parser.xml.assembler.mock;

import hex.di.ISpeedInjectorContainer;
import hex.control.Request;
import hex.control.command.BasicCommand;
import hex.ioc.assembler.ApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class MockStateCommand extends BasicCommand implements ISpeedInjectorContainer
{
	static public var callCount : Int = 0;
	static public var lastInjecteContext : ApplicationContext;
	
	@Inject
	public var context : ApplicationContext;
	
	override public function execute( ?request : Request ) : Void 
	{
		MockStateCommand.callCount++;
		MockStateCommand.lastInjecteContext = this.context;
	}
}