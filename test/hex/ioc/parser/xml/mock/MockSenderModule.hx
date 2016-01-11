package hex.ioc.parser.xml.mock;

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
		this.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "hello receiver" ] );
	}
}