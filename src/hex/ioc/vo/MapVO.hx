package hex.ioc.vo;
import haxe.macro.Expr.Position;

/**
 * ...
 * @author Francis Bourre
 */
class MapVO
{
	var _key 	: ConstructorVO;
	var _value 	: ConstructorVO;

	public var key 			: Dynamic;
	public var value 		: Dynamic;
	public var mapName 		: String;
	public var asSingleton 	: Bool = false;
	public var injectInto 	: Bool = false;
	
	#if macro
	public var filePosition : Position;
	#end

	public function new( key : ConstructorVO, value : ConstructorVO, ?mapName : String, asSingleton : Bool = false, injectInto : Bool = false )
	{
		this._key 			= key;
		this._value 		= value;
		this.mapName 		= mapName;
		this.asSingleton 	= asSingleton;
		this.injectInto 	= injectInto;
	}

	public function getPropertyKey() : ConstructorVO
	{
		return this._key;
	}

	public function getPropertyValue() : ConstructorVO
	{
		return this._value;
	}
}