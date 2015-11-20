package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class DomainListenerVO
{

	public var ownerID 				: String;
	public var listenedDomainName 	: String;
	public var arguments 			: Array<DomainListenerVOArguments>;

	public function new( ownerID : String, listenedDomainName : String, ?arguments : Array<DomainListenerVOArguments> )
	{
		this.ownerID 				= ownerID;
		this.listenedDomainName 	= listenedDomainName;
		this.arguments 				= arguments;
	}

	public function toString() : String
	{
		return this + "(" + "ownerID:" + ownerID + ", " + "listenedDomainName:" + listenedDomainName + ", " + "arguments:[" + arguments + "])";
	}
}