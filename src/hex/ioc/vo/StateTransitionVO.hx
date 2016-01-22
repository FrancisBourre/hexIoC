package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class StateTransitionVO
{
	public var ID					: String;
	public var stateClassReference	: String;
	public var enterList			: Array<CommandMappingVO>;
	public var exitList				: Array<CommandMappingVO>;

	public function new( ID : String, stateClassReference : String, enterList : Array<CommandMappingVO>, exitList : Array<CommandMappingVO> ) 
	{
		this.ID 					= ID;
		this.stateClassReference 	= stateClassReference;
		this.enterList 				= enterList;
		this.exitList 				= exitList;
	}
}