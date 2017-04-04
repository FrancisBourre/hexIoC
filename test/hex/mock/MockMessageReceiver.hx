package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockMessageReceiver implements IMessageReceiver
{
	public var message : String;

	public function new() 
	{
		
	}
	
	public function receive( message : String ) : Void 
	{
		this.message = message;
	}
}