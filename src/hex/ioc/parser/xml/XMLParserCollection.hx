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
	
	override protected function _buildParserList() : Void
	{
		//this._parserCommandCollection.push( new DisplayObjectXMLParser() );
		//this._parserCommandCollection.push( new ObjectXMLParser() );
	}
}