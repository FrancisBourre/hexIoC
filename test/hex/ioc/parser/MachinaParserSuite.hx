package hex.ioc.parser;
import hex.ioc.parser.xml.MachinaXmlSuite;

/**
 * ...
 * @author Francis Bourre
 */
class MachinaParserSuite
{
	@suite( "Parser" )
    public var list : Array<Class<Dynamic>> = [MachinaXmlSuite];
}