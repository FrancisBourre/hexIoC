package hex;

import hex.ioc.IOCSuite;

/**
 * ...
 * @author Francis Bourre
 */
class HexIoCSuite
{
	@Suite( "HexIoC suite" )
    public var list : Array<Class<Dynamic>> = [IOCSuite];
}