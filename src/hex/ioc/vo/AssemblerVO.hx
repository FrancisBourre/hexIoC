package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class AssemblerVO
{
	function new() {}
	
	#if macro
	public var filePosition	: haxe.macro.Expr.Position;
	#end
	
	public var ifList 		: Array<String> = null;
	public var ifNotList 	: Array<String> = null;
}