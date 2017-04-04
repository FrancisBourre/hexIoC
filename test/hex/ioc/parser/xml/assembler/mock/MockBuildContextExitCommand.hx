package hex.ioc.parser.xml.assembler.mock;

import hex.compiler.parser.xml.XmlCompiler;
import hex.control.command.BasicCommand;
import hex.core.IApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class MockBuildContextExitCommand extends BasicCommand
{
	static public var callCount : Int = 0;
	static public var lastInjecteContext : IApplicationContext;
	
	@Inject
	public var context : IApplicationContext;
	
	override public function execute() : Void
	{
		MockBuildContextExitCommand.callCount++;
		MockBuildContextExitCommand.lastInjecteContext = this.context;
	}
}