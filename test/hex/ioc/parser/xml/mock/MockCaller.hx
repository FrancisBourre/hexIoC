package hex.ioc.parser.xml.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockCaller
{
	public static var passedArguments : Array<String>;
	
	public function new() 
	{
		
	}
	
	public function call( a : String, b : String ) : Void
	{
		MockCaller.passedArguments = [ a, b ];
	}
}