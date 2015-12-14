package hex.ioc;

import hex.ioc.assembler.MachinaAssemblerSuite;
import hex.ioc.control.MachinaControlSuite;
import hex.ioc.core.MachinaCoreSuite;
import hex.ioc.parser.MachinaParserSuite;
import hex.ioc.vo.MachinaVOSuite;

/**
 * ...
 * @author Francis Bourre
 */
class MachinaIOCSuite
{
	@suite( "IOC" )
    public var list : Array<Class<Dynamic>> = [MachinaAssemblerSuite, MachinaControlSuite, MachinaCoreSuite, MachinaParserSuite, MachinaVOSuite];
}