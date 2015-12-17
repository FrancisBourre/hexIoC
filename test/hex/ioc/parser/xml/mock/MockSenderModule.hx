package hex.ioc.parser.xml.mock;

import hex.control.payload.ExecutionPayload;
import hex.control.payload.PayloadEvent;

/**
 * ...
 * @author Francis Bourre
 */
class MockSenderModule extends MockModule
{
	public function new() 
	{
		super();
	}
	
	override public function initialize() : Void
	{
		this.dispatchDomainEvent( new PayloadEvent( MockChatModule.TEXT_INPUT, this, [ new ExecutionPayload( "hello receiver", String ) ] ) );
	}
}