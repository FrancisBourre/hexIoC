package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class MapVO
{
	var _key 	: PropertyVO;
	var _value 	: PropertyVO;

	public var key 		: Dynamic;
	public var value 	: Dynamic;

	public function new( key : PropertyVO, value : PropertyVO )
	{
		this._key 	= key;
		this._value = value;
	}

	public function getPropertyKey() : PropertyVO
	{
		return this._key;
	}

	public function getPropertyValue() : PropertyVO
	{
		return this._value;
	}
	
}