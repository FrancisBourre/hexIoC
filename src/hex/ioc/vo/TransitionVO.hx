package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
typedef TransitionVO = 
{
	public var messageReference			: String;
	public var stateReference			: String;
	
	#if macro
	@:optional var filePosition		: haxe.macro.Expr.Position;
	#end
}