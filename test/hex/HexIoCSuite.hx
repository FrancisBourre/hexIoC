package hex;

import hex.compiler.CompilerSuite;
import hex.ioc.IOCSuite;

/**
 * ...
 * @author Francis Bourre
 */
class HexIoCSuite
{
	@Suite( "HexIoC suite" )
    public var list : Array<Class<Dynamic>> = [ CompilerSuite, IOCSuite ];
}