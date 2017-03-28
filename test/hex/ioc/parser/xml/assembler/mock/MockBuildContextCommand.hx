package hex.ioc.parser.xml.assembler.mock;

import hex.compiler.parser.xml.assembler.BuildTwoContextsWithStateTransitionsTest;
import hex.control.command.BasicCommand;
import hex.core.IApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class MockBuildContextCommand extends BasicCommand
{
	static public var callCount : Int = 0;
	static public var lastInjecteContext : IApplicationContext;
	
	@Inject
	public var context : IApplicationContext;
	
	override public function execute() : Void
	{
		MockBuildContextCommand.callCount++;

		var xml = XmlReader.getXml( "context/testBuildingStateTransitionsSecondPass.xml" );
		ApplicationXMLParser.parseXml( BuildTwoContextsWithStateTransitionsTest.applicationAssembler, xml );
	}
}