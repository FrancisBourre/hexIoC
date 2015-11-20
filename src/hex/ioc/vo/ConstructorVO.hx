package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class ConstructorVO
{
	public var              ID              : String;
	public var              type            : String;
	public var              arguments       : Array;
	public var              factory         : String;
	public var              singleton       : String;
	public var              ref             : String;
	public var              result          : Dynamic;
	public var 				mapType			: String;
	public var 				staticRef		: String;
		
	public function new(  	id 				: String,
							?type 			: String,
							?args 			: Array<Dynamic>,
							?factory 		: String,
							?singleton 		: String,
							?ref 			: String,
							?mapType 		: String,
							?staticRef 		: String )
	{
		this.ID         = id;
		this.type       = type;
		this.arguments  = args;
		this.factory    = factory;
		this.singleton  = singleton;
		this.ref 		= ref;
		this.mapType 	= mapType;
		this.staticRef 	= staticRef;
	}

	public function toString() : String
	{
		return 	"("
				+ "id:"                 + ID            + ", "
				+ "type:"               + type          + ", "
				+ "arguments:[" 		+ arguments 	+ "], "
				+ "factory:"    		+ factory       + ", "
				+ "singleton:"  		+ singleton 	+ ", "
				+ "ref:"  				+ ref 			+ ", "
				+ "mapType:"  			+ mapType 		+ ", "
				+ "staticRef:"          + staticRef     + ")";
	}
}