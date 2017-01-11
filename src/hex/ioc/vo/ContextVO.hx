package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class ContextVO extends AssemblerVO
{
	public var name 		: String;
	public var className 	: String;
	
	public function new( name : String, className : String ) 
	{
		super();
		
		this.name 		= name;
		this.className 	= className;
	}
}