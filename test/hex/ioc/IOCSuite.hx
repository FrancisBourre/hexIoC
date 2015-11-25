package hex.ioc;

import hex.ioc.control.ControlSuite;
import hex.ioc.vo.VOSuite;

/**
 * ...
 * @author Francis Bourre
 */
class IOCSuite
{
	@suite( "IOC suite" )
    public var list : Array<Class<Dynamic>> = [ControlSuite, VOSuite];
}