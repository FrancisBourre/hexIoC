package hex.ioc.parser.xml.assembler.mock;

import hex.compiler.parser.xml.assembler.BuildTwoContextsWithStateTransitionsTest;
import hex.ioc.parser.xml.ApplicationXMLParser;
import hex.ioc.parser.xml.XmlReader;
import hex.module.Module;
import hex.module.dependency.IRuntimeDependencies;
import hex.module.dependency.RuntimeDependencies;
import hex.state.State;

/**
 * ...
 * @author Francis Bourre
 */
class MockBuilderModule extends Module
{
	public function new() 
	{
		super();
	}
	
	override function _getRuntimeDependencies() : IRuntimeDependencies 
	{
		return new RuntimeDependencies();
	}
	
	public function build( state : State ) : Void
	{
		state.removeEnterHandler( this.build );
		var xml = XmlReader.getXml( "context/testBuildingStateTransitionsSecondPass.xml" );
		ApplicationXMLParser.parseXml( BuildTwoContextsWithStateTransitionsTest.applicationAssembler, xml );
	}
}