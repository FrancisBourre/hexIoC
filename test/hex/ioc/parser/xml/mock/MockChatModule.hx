package hex.ioc.parser.xml.mock;

import hex.control.payload.ExecutionPayload;
import hex.control.payload.PayloadEvent;

/**
 * ...
 * @author Francis Bourre
 */
class MockChatModule extends MockModule
{
	static public inline var TEXT_INPUT : String = "onTextInput";
	
	public function new() 
	{
		super();
	}
	
	public var translatedMessage 	: String;
	public var date 				: Date;

	public function onTranslation( event : PayloadEvent ) : Void
	{
		var payloads : Array<ExecutionPayload> 	= event.getExecutionPayloads();
		this.translatedMessage 					= payloads[0].getData();
		
		if ( payloads.length > 1 )
		{trace( payloads[1].getData() );
			this.date = payloads[1].getData();
		}
	}
}