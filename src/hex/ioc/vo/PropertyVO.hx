package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class PropertyVO extends AssemblerVO
{
	public var ownerID 		: String;
	public var name 		: String;
	public var value 		: String;
	public var type 		: String;
	public var ref 			: String;
	public var method 		: String;
	public var staticRef 	: String;

	public function new(    ownerID 	: String,
							?name    	: String,
							?value   	: String,
							?type    	: String,
							?ref     	: String,
							?method  	: String,
							?staticRef  : String )
		{
			super();
			
			this.ownerID 	= ownerID;
			this.name 		= name;
			this.value 		= value;
			this.type 		= type;
			this.ref 		= ref;
			this.method 	= method;
			this.staticRef 	= staticRef;
		}

		/*public function toString() : String
		{
			return 	"("
					+ "ownerID:"    		+ ownerID       + ", "
					+ "name:"               + name          + ", "
					+ "value:"              + value         + ", "
					+ "type:"               + type          + ", "
					+ "ref:"                + ref           + ", "
					+ "method:"     		+ method       + ", "
					+ "staticRef:"     		+ staticRef     + ")";
		}*/
}