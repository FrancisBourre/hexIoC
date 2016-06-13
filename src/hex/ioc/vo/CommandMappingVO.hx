package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class CommandMappingVO
{
	public var commandClassName : String;
	public var fireOnce 		: Bool;
	public var contextOwner 	: String;
	
	public function new( commandClassName : String, fireOnce : Bool = false, contextOwner : String = null ) 
	{
		this.commandClassName 	= commandClassName;
		this.fireOnce 			= fireOnce;
		this.contextOwner 		= contextOwner;
	}
}