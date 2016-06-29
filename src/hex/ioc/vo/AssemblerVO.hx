package hex.ioc.vo;

import haxe.macro.Expr.Position;

/**
 * ...
 * @author Francis Bourre
 */
class AssemblerVO
{
	public function new() 
	{
		
	}
	

	public var filePosition				: Position;
	public var ifList 					: Array<String> = null;
	public var ifNotList 				: Array<String> = null;
}