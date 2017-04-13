package hex.compiler.parser.xml;

#if macro
import hex.core.VariableExpression;

/**
 * ...
 * @author Francis Bourre
 */
class ParserCollection extends hex.parser.AbstractParserCollection<hex.compiletime.xml.AbstractXmlParser<hex.factory.BuildRequest>>
{
	var _assemblerVariable : VariableExpression;
	
	public function new( assemblerVariable : VariableExpression ) 
	{
		this._assemblerVariable = assemblerVariable;
		super();
	}
	
	override function _buildParserList() : Void
	{
		this._parserCollection.push( new ApplicationContextParser( this._assemblerVariable ) );
		this._parserCollection.push( new StateParser() );
		this._parserCollection.push( new ObjectParser() );
		this._parserCollection.push( new Launcher( this._assemblerVariable ) );
	}
}
#end