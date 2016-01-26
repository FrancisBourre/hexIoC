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
	
	override function _buildParserList() : Void
	{
		this._parserCommandCollection.push( new ApplicationContextXMLParser() );
		this._parserCommandCollection.push( new StateXMLParser() );
		this._parserCommandCollection.push( new ObjectXMLParser() );
	}
}