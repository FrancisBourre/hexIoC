package hex.ioc.parser.xml;

/**
 * ...
 * @author Francis Bourre
 */
class MachinaXmlSuite
{
	@suite( "Xml" )
    public var list : Array<Class<Dynamic>> = [ObjectXMLParserTest, XmlParserUtilTest];
	
}