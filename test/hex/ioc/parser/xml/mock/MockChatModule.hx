package hex.ioc.parser.xml.mock;

import hex.event.MessageType;

/**
 * ...
 * @author Francis Bourre
 */
class MockChatModule extends MockModule
{
	static public var TEXT_INPUT = new MessageType( "onTextInput" );
	
	public function new() 
	{
		super();
	}
	
	public var translatedMessage 	: String;
	public var date 				: Date;

	public function onTranslation( translatedMessage : String, ?date : Date ) : Void
	{
		this.translatedMessage = translatedMessage;
		this.date = date;
	}
}