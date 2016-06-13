package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class MethodCallVO extends AssemblerVO
{
	public var ownerID              : String;
	public var name                 : String;
	public var arguments    		: Array<Dynamic>;

	public function new ( ownerID : String, name : String, args : Array<Dynamic> )
	{
		super();
		
		this.ownerID    = ownerID;
		this.name       = name ;
		this.arguments  = args ;
	}
}