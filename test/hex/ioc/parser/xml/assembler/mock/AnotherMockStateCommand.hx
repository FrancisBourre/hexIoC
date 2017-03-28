package hex.ioc.parser.xml.assembler.mock;

import hex.control.command.BasicCommand;
import hex.core.IApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class AnotherMockStateCommand extends BasicCommand
{
	static public var callCount : Int = 0;
	static public var lastInjectedContext: IApplicationContext;
	
	@Inject
	public var context : IApplicationContext;
	
	override public function execute() : Void
	{
		AnotherMockStateCommand.callCount++;
		AnotherMockStateCommand.lastInjectedContext = this.context;
	}
}