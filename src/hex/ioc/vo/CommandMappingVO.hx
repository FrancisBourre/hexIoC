package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
typedef CommandMappingVO = 
{
	var methodRef 			: String;
	
	var commandClassName 	: String;
	var fireOnce 			: Bool;
	var contextOwner 		: String;
	
	#if macro
	@:optional var filePosition		: haxe.macro.Expr.Position;
	#end
}