package hex.compiler;

import hex.compiler.parser.CompilerParserSuite;

/**
 * ...
 * @author Francis Bourre
 */
class CompilerSuite
{
	@Suite( "Compiler" )
    public var list : Array<Class<Dynamic>> = [ CompilerParserSuite ];
}