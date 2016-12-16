package hex.compiler.parser.flow;

import haxe.macro.Expr;
import hex.ioc.parser.AbstractParserCollection;

/**
 * ...
 * @author Francis Bourre
 */
class ParserCollection extends AbstractParserCollection<AbstractExprParser, Expr>
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
