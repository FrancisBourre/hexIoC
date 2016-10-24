package hex.ioc.vo;

import hex.state.State;

/**
 * ...
 * @author Francis Bourre
 */
class TransitionVO
{
	public function new()
	{
		
	}
	
	public var stateVarName			: String;
	public var messageReference		: String;
	public var stateReference		: String;
	
	#if macro
	public var filePosition			: haxe.macro.Expr.Position;
	#end
}