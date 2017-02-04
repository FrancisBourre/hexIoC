package hex.ioc.parser.xml;

import hex.factory.BuildRequest;
import hex.parser.AbstractParserCollection;
import hex.runtime.xml.AbstractXMLParser;

/**
 * ...
 * @author Francis Bourre
 */
class XMLParserCollection extends AbstractParserCollection<AbstractXMLParser, Xml>
{
	private var _isAutoBuild : Bool = false;
	
	public function new( isAutoBuild : Bool = false ) 
	{
		this._isAutoBuild = isAutoBuild;
		super();
	}
	
	override function _buildParserList() : Void
	{
		this._parserCollection.push( new StateXMLParser() );
		this._parserCollection.push( new ObjectXMLParser() );

		if ( this._isAutoBuild )
		{
			this._parserCollection.push( new AutoBuildLauncher() );
		}
	}
}