package hex;

import hex.compiler.CompilerSuite;
import hex.factory.FactorySuite;
import hex.ioc.IOCSuite;
import hex.util.FastEvalTest;

/**
 * ...
 * @author Francis Bourre
 */
class HexIoCSuite
{
	@Suite( "HexIoC suite" )
    public var list : Array<Class<Dynamic>> = [ CompilerSuite, FactorySuite, IOCSuite, FastEvalTest ];
}