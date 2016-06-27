package hex.ioc.vo;

import haxe.macro.Expr.Position;
import hex.ioc.error.IAssemblingExceptionReporter;

/**
 * ...
 * @author Francis Bourre
 */
class AssemblerVO
{
	public function new() 
	{
		
	}
	
	#if macro
	public var				filePosition	: Position;
	#end
	
	public var ifList 					: Array<String> = null;
	public var ifNotList 				: Array<String> = null;
	
	public var exceptionReporter		: IAssemblingExceptionReporter;
}