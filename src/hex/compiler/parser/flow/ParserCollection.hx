package hex.compiler.parser.flow;

#if macro
import hex.core.VariableExpression;

/**
 * ...
 * @author Francis Bourre
 */
class ParserCollection extends hex.parser.AbstractParserCollection<hex.compiletime.flow.AbstractExprParser<hex.factory.BuildRequest>>
{
	var _assemblerVariable : VariableExpression;
	
	public function new( assemblerVar : VariableExpression ) 
	{
		this._assemblerVariable = assemblerVar;
		super();
	}
	
	override function _buildParserList() : Void
	{
		this._parserCollection.push( new ApplicationContextParser( this._assemblerVariable ) );
		this._parserCollection.push( new StateParser( hex.compiletime.flow.parser.FlowExpressionParser.parser ) );
		this._parserCollection.push( new ObjectParser( hex.compiletime.flow.parser.FlowExpressionParser.parser/*, this._runtimeParam*/ ) );
		this._parserCollection.push( new Launcher( this._assemblerVariable ) );
	}
}
#end