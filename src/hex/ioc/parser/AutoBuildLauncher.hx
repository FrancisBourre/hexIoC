package hex.ioc.parser;

import hex.factory.BuildRequest;
import hex.runtime.xml.AbstractXMLParser;

/**
 * ...
 * @author Francis Bourre
 */
class AutoBuildLauncher extends AbstractXMLParser<BuildRequest>
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