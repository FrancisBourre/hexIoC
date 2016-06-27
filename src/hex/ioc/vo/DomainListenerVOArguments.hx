package hex.ioc.vo;

import haxe.macro.Expr.Position;

/**
 * ...
 * @author Francis Bourre
 */
class DomainListenerVOArguments
{
	public var staticRef 		: String;
	public var method 			: String;
	public var strategy 		: String;
	public var injectedInModule : Bool = false;
	
	#if macro
	public var				filePosition	: Position;
	#end

	public function new( ?staticRef : String, ?method : String, ?strategy : String, ?injectedInModule : Bool = false )
	{
		this.staticRef 			= staticRef;
		this.method 			= method;
		this.strategy 			= strategy;
		this.injectedInModule 	= injectedInModule;
	}
}