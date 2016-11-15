package hex.compiler.parser.xml;

import hex.compiler.parser.xml.assembler.ApplicationAssemblerStateTest;
import hex.compiler.parser.xml.state.StatefulStateMachineConfigTest;
import hex.compiler.parser.xml.context.ApplicationContextBuildingTest;

/**
 * ...
 * @author Francis Bourre
 */
class CompilerXmlSuite
{
	@Suite( "Xml" )
    public var list : Array<Class<Dynamic>> = [ ApplicationAssemblerStateTest, ApplicationContextBuildingTest, StatefulStateMachineConfigTest, XmlCompilerBuildsTwoContext, XmlCompilerTest ];
}