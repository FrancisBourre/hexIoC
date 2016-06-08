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
	
	public var ifList 				: Array<String> = null;
	public var ifNotList 			: Array<String> = null;

	public function new( ownerID : String, listenedDomainName : String, ?arguments : Array<DomainListenerVOArguments> )
	{
		this.ownerID 				= ownerID;
		this.listenedDomainName 	= listenedDomainName;
		this.arguments 				= arguments;
	}
}