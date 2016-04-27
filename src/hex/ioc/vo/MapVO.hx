package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class MapVO
{
	var _key 	: ConstructorVO;
	var _value 	: ConstructorVO;

	public var key 		: Dynamic;
	public var value 	: Dynamic;

	public function new( key : ConstructorVO, value : ConstructorVO )
	{
		this._key 	= key;
		this._value = value;
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