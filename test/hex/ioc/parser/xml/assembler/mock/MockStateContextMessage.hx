package hex.ioc.parser.xml.assembler.mock;
import hex.event.MessageType;

/**
 * ...
 * @author Francis Bourre
 */
class MockStateContextMessage
{
	static public var APPLICATION_INIT 	: MessageType = new MessageType( "onApplicationInit" );
	static public var SWITCH_STATE 		: MessageType = new MessageType( "onSwitchState" );
	static public var SWITCH_BACK 		: MessageType = new MessageType( "onSwitchBack" );
	
	private function new() 
	{
		
	}
}