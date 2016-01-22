package hex.ioc.parser.xml;

import hex.ioc.parser.xml.assembler.ApplicationAssemblerStateTest;
import hex.ioc.parser.xml.context.ApplicationContextBuildingTest;
import hex.ioc.parser.xml.state.StatefulStateMachineConfigTest;

/**
 * ...
 * @author Francis Bourre
 */
class MachinaXmlSuite
{
	@Suite( "Xml" )
    public var list : Array<Class<Dynamic>> = [ApplicationAssemblerStateTest, ApplicationContextBuildingTest, ObjectXMLParserTest, StatefulStateMachineConfigTest, XmlParserUtilTest];
	
}