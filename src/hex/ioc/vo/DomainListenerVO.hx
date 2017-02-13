package hex.ioc.vo;
import hex.vo.AssemblerVO;

/**
 * ...
 * @author Francis Bourre
 */
class DomainListenerVO extends AssemblerVO
{

	public var ownerID 				: String;
	public var listenedDomainName 	: String;
	public var arguments 			: Array<DomainListenerVOArguments>;

	public function new( ownerID : String, listenedDomainName : String, ?arguments : Array<DomainListenerVOArguments> )
	{
		super();
		
		this.ownerID 				= ownerID;
		this.listenedDomainName 	= listenedDomainName;
		this.arguments 				= arguments;
	}
}