package hex.ioc;

import hex.ioc.assembler.IoCAssemblerSuite;
import hex.ioc.core.IoCCoreSuite;
import hex.ioc.parser.IoCParserSuite;
import hex.ioc.vo.IoCVOSuite;

/**
 * ...
 * @author Francis Bourre
 */
class IOCSuite
{
	@Suite( "IOC" )
    public var list : Array<Class<Dynamic>> = [ IoCAssemblerSuite, IoCCoreSuite, IoCParserSuite, IoCVOSuite ];
}