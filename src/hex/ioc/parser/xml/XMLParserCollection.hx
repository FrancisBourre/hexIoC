package hex.ioc.parser.xml;

import hex.ioc.parser.AbstractParserCollection;

/**
 * ...
 * @author Francis Bourre
 */
class XMLParserCollection extends AbstractParserCollection
{
	public function new() 
	{
		super();
	}
	
	override private function _buildParserList() : Void
	{
		this._parserCommandCollection.push( new ApplicationContextXMLParser() );
		this._parserCommandCollection.push( new ObjectXMLParser() );
	}
}