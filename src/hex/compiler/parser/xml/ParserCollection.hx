package hex.compiler.parser.xml;

import hex.factory.BuildRequest;
import hex.parser.AbstractParserCollection;

/**
 * ...
 * @author Francis Bourre
 */
class ParserCollection extends AbstractParserCollection<AbstractXmlParser, Xml>
{
	public function new() 
	{
		super();
	}
	
	override function _buildParserList() : Void
	{
		this._parserCommandCollection.push( new ApplicationContextParser() );
		this._parserCommandCollection.push( new StateParser() );
		this._parserCommandCollection.push( new ObjectParser() );
		this._parserCommandCollection.push( new Launcher() );
	}
}
