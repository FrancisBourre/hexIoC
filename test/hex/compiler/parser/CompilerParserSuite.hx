package hex.compiler.parser;

import hex.compiler.parser.xml.CompilerXmlSuite;

/**
 * ...
 * @author Francis Bourre
 */
class CompilerParserSuite
{
	@Suite( "Parser" )
    public var list : Array<Class<Dynamic>> = [ CompilerXmlSuite ];
}