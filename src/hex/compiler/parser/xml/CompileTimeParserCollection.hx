package hex.compiler.parser.xml;

import hex.ioc.parser.AbstractParserCollection;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeParserCollection extends AbstractParserCollection<CompileTimeXMLParser>
{
	public function new() 
	{
		super();
	}
	
	override function _buildParserList() : Void
	{
		this._parserCommandCollection.push( new CompileTimeApplicationContextParser() );
		this._parserCommandCollection.push( new CompileTimeStateParser() );
		this._parserCommandCollection.push( new CompileTimeObjectParser() );
		this._parserCommandCollection.push( new CompileTimeLauncher() );
	}
}
