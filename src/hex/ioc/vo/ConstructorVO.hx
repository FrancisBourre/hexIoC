package hex.ioc.vo;

import haxe.macro.Expr;

/**
 * ...
 * @author Francis Bourre
 */
class ConstructorVO extends AssemblerVO
{
	public var              ID              	: String;
	public var              type            	: String;
	public var              arguments       	: Array<Dynamic>;
	public var              factory         	: String;
	public var              singleton       	: String;
	public var              injectInto      	: Bool;
	public var              ref             	: String;
	public var              result          	: Dynamic;
	public var 				mapTypes			: Array<String>;
	public var 				staticRef			: String;
	public var              injectorCreation 	: Bool;
	
	#if macro
	public var 				isProperty		: Bool = false;
	public var 				constructorArgs	: Array<Expr>;
	#end
		
	public function new(  	id 					: String,
							?type 				: String,
							?args 				: Array<Dynamic>,
							?factory 			: String,
							?singleton 			: String,
							?injectInto 		: Bool = false,
							?ref 				: String,
							?mapTypes 			: Array<String>,
							?staticRef 			: String,
							?injectorCreation 	: Bool )
	{
		super();
		
		this.ID         		= id;
		this.type       		= type;
		this.arguments  		= args;
		this.factory    		= factory;
		this.singleton  		= singleton;
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
				+ "type:"               + type          	+ ", "
				+ "arguments:[" 		+ arguments 		+ "], "
				+ "factory:"    		+ factory       	+ ", "
				+ "singleton:"  		+ singleton 		+ ", "
				+ "injectInto:"  		+ injectInto 		+ ", "
				+ "ref:"  				+ ref 				+ ", "
				+ "mapTypes:"  			+ mapTypes 			+ ", "
				+ "staticRef:"          + staticRef 		+ ")"
				+ "injectorCreation:"   + injectorCreation 	+ ")";
	}
}