package hex.compiler.parser.xml;

import hex.compiler.parser.xml.assembler.ApplicationAssemblerStateTest;
import hex.compiler.parser.xml.assembler.BuildTwoContextsWithStateTransitionsTest;
import hex.compiler.parser.xml.context.ApplicationContextBuildingTest;
import hex.compiler.parser.xml.state.StatefulStateMachineConfigTest;

/**
 * ...
 * @author Francis Bourre
 */
class CompilerXmlSuite
{
	@Suite( "Xml" )
    public var list : Array<Class<Dynamic>> = 
	[ 
		ApplicationAssemblerStateTest, 
		ApplicationContextBuildingTest, 
		BuildTwoContextsWithStateTransitionsTest,
		StatefulStateMachineConfigTest, 
		XmlCompilerTest 
	];
}