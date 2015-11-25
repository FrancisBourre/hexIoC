package hex;

import hex.ioc.IOCSuite;

/**
 * ...
 * @author Francis Bourre
 */
class HexMachinaSuite
{
	@suite( "HexMachina suite" )
    public var list : Array<Class<Dynamic>> = [IOCSuite];
}