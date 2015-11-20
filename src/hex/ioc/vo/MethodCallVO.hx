package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class MethodCallVO
{
	public var ownerID              : String;
	public var name                 : String;
	public var arguments    		: Array<Dynamic>;

	public function new ( ownerID : String, name : String, args : Array<Dynamic> )
	{
		this.ownerID    = ownerID;
		this.name       = name ;
		this.arguments  = args ;
	}

	public function toString() : String
	{
		return 	this   	+ "("
						+ "ownerID:"    + ownerID       + ", "
						+ "name:"       + name          + ", "
						+ "arguments:[" + arguments 	+ "])";
	}
}