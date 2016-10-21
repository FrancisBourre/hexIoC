package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class StateTransitionVO extends AssemblerVO
{
	public var ID						: String;
	public var staticReference			: String;
	public var instanceReference		: String;
	public var enterList				: Array<CommandMappingVO>;
	public var exitList					: Array<CommandMappingVO>;
	public var transitionList			: Array<TransitionVO>;
	
	#if macro
	public var expressions 				: Array<haxe.macro.Expr>;
	#end

	public function new( 	ID 					: String, 
							staticReference 	: String, 
							instanceReference 	: String, 
							enterList 			: Array<CommandMappingVO>, 
							exitList 			: Array<CommandMappingVO>, 
							transitionList		: Array<TransitionVO> ) 
	{
		super();
		
		this.ID 					= ID;
		this.staticReference 		= staticReference;
		this.instanceReference 		= instanceReference;
		this.enterList 				= enterList;
		this.exitList 				= exitList;
		this.transitionList 		= transitionList;
	}
}