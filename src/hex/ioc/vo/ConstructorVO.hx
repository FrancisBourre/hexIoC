package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class ConstructorVO extends AssemblerVO
{
	public var              ID              	: String;
	public var              type            	: String;
	public var              className           : String;
	public var              arguments       	: Array<Dynamic>;
	public var              factory         	: String;
	public var              staticCall       	: String;
	public var              injectInto      	: Bool;
	public var              ref             	: String;
	public var 				mapTypes			: Array<String>;
	public var 				staticRef			: String;
	public var              injectorCreation 	: Bool;
	
	public var 				shouldAssign		= true;
		
	public function new(  	id 					: String,
							?type 				: String,
							?args 				: Array<Dynamic>,
							?factory 			: String,
							?staticCall 		: String,
							?injectInto 		: Bool = false,
							?ref 				: String,
							?mapTypes 			: Array<String>,
							?staticRef 			: String,
							?injectorCreation 	: Bool )
	{
		super();
		
		this.ID         		= id;
		this.type       		= type;
		this.className       	= type != null ? type.split( '<' )[ 0 ] : null;
		this.arguments  		= args;
		this.factory    		= factory;
		this.staticCall  		= staticCall;
		this.injectInto 		= injectInto;
		this.ref 				= ref;
		this.mapTypes 			= mapTypes;
		this.staticRef 			= staticRef;
		this.injectorCreation 	= injectorCreation;
	}

	public function toString() : String
	{
		return 	"("
				+ "id:"                 + ID            	+ ", "
				+ "type:"               + type 				+ ", "
				+ "className:"          + className         + ", "
				+ "arguments:[" 		+ arguments 		+ "], "
				+ "factory:"    		+ factory       	+ ", "
				+ "staticCall:"  		+ staticCall 		+ ", "
				+ "injectInto:"  		+ injectInto 		+ ", "
				+ "ref:"  				+ ref 				+ ", "
				+ "mapTypes:"  			+ mapTypes 			+ ", "
				+ "staticRef:"          + staticRef 		+ ", "
				+ "injectorCreation:"   + injectorCreation 	+ ", "
				+ "shouldAssign:"   	+ shouldAssign 		+ ")";
	}
}