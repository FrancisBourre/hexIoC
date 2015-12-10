package hex;

import hex.ioc.MachinaIOCSuite;

/**
 * ...
 * @author Francis Bourre
 */
class HexMachinaSuite
{
	@suite( "HexMachina suite" )
    public var list : Array<Class<Dynamic>> = [MachinaIOCSuite];
}