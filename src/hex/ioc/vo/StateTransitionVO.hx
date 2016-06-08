package hex.ioc.vo;

#if macro
import haxe.macro.Expr;
#end

/**
 * ...
 * @author Francis Bourre
 */
class StateTransitionVO
{
	public var ID						: String;
	public var staticReference			: String;
	public var instanceReference		: String;
	public var enterList				: Array<CommandMappingVO>;
	public var exitList					: Array<CommandMappingVO>;
	
	public var ifList 					: Array<String> = null;
	public var ifNotList 				: Array<String> = null;
	
	#if macro
	public var expressions 				: Array<Expr>;
	#end

	public function new( ID : String, staticReference : String, instanceReference : String, enterList : Array<CommandMappingVO>, exitList : Array<CommandMappingVO> ) 
	{
		this.ID 					= ID;
		this.staticReference 		= staticReference;
		this.instanceReference 		= instanceReference;
		this.enterList 				= enterList;
		this.exitList 				= exitList;
		
		
	}
}