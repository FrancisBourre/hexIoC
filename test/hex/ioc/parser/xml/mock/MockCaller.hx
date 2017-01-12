package hex.ioc.parser.xml.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockCaller
{
	public static var passedArguments : Array<String>;
	public static var passedArray : Array<IMockFruit>;
	
	
	public function new() 
	{
		
	}
	
	public function call( a : String, b : String ) : Void
	{
		MockCaller.passedArguments = [ a, b ];
	}
	
	public function callArray( callArray:Array<IMockFruit> ) : Void
	{
		MockCaller.passedArray = callArray;
	}
	
	
}