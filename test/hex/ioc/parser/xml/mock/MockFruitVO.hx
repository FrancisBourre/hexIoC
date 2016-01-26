package hex.ioc.parser.xml.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockFruitVO
{
	var _name : String;

	public function new( name : String )
	{
		this._name = name;
	}

	public function toString() : String
	{
		return this._name;
	}
}