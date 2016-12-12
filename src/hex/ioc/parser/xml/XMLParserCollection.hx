package hex.ioc.parser.xml;

import hex.ioc.parser.AbstractParserCollection;

/**
 * ...
 * @author Francis Bourre
 */
class XMLParserCollection extends AbstractParserCollection<AbstractXMLParser>
{
	private var _isAutoBuild : Bool = false;
	
	public function new( isAutoBuild : Bool = false ) 
	{
		this._isAutoBuild = isAutoBuild;
		super();
	}
	
	override function _buildParserList() : Void
	{
		this._parserCommandCollection.push( new ApplicationContextXMLParser() );
		this._parserCommandCollection.push( new StateXMLParser() );
		this._parserCommandCollection.push( new ObjectXMLParser() );

		if ( this._isAutoBuild )
		{
			this._parserCommandCollection.push( new AutoBuildLauncher() );
		}
	}
}