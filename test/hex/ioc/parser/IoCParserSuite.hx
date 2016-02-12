package hex.ioc.parser;
import hex.ioc.parser.xml.IoCXmlSuite;

/**
 * ...
 * @author Francis Bourre
 */
class IoCParserSuite
{
	@Suite( "Parser" )
    public var list : Array<Class<Dynamic>> = [IoCXmlSuite];
}