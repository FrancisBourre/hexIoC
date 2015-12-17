package hex.ioc.parser.xml.mock;
import hex.control.payload.PayloadEvent;

/**
 * ...
 * @author Francis Bourre
 */
class MockReceiverModule extends MockModule
{
	public function new() 
	{
		super();
	}
	
	public var message : String;

	public function onMessage( text : String ) : Void
	{
		this.message = text;
	}
	
	public function onMessageEvent( event : PayloadEvent ) : Void
	{
		this.message = event.getExecutionPayloads()[0].getData();
	}
}