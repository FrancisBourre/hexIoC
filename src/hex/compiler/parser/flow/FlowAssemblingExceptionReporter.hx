package hex.compiler.parser.flow;

import haxe.macro.Expr;
import hex.ioc.error.IAssemblingExceptionReporter;

/**
 * ...
 * @author Francis Bourre
 */
class FlowAssemblingExceptionReporter implements IAssemblingExceptionReporter<Expr>
{
	public function new() 
	{
		
	}
	
	public function getPosition( e : Expr, ?additionalInformations : Dynamic ) : Position
	{
		//return additionalInformations == null ? this._positionTracker.makePositionFromNode( xml ) : this._positionTracker.makePositionFromAttribute( xml, additionalInformations );
		return null;
	}
}