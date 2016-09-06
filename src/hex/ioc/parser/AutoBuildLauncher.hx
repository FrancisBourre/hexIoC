package hex.ioc.parser;

import hex.ioc.parser.xml.AbstractXMLParser;

/**
 * ...
 * @author Francis Bourre
 */
class AutoBuildLauncher extends AbstractXMLParser
{
	public function new() 
	{
		super();
	}
	
	override public function parse() : Void
	{
		this._applicationAssembler.buildEverything();
	}
}