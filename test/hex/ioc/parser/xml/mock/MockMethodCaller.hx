package hex.ioc.parser.xml.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockMethodCaller 
{
	inline public static var staticVar : Int = 3;
	
	public var argument : Int;
	
	public function new() 
	{
		
	}
	
	public function call( i : Int ) : Void
	{
		this.argument = i;
	}
}