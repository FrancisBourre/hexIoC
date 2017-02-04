package hex.ioc.parser;

import hex.runtime.xml.AbstractXMLParser;

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