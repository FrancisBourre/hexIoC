package hex.ioc.parser.xml.mock;
import hex.control.payload.PayloadEvent;

/**
 * ...
 * @author Francis Bourre
 */
class MockChatModule extends MockModule
{
	public function new() 
	{
		super();
	}
	
	public var translatedMessage 	: String;
	public var date 				: Date;

	public function onTranslation( event : PayloadEvent ) : Void
	{
		this.translatedMessage = event.getExecutionPayloads()[0].getData();
	}

	/*public function onAnotherTranslation( event : PayloadEvent ) : Void
	{
		this.translatedMessage = event.getExecutionPayloads()[0].getData();
		this.date = event.getExecutionPayloads()[1].getData();
	}*/
}