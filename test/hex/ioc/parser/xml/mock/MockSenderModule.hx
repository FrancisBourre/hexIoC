package hex.ioc.parser.xml.mock;

import hex.core.IApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class MockSenderModule extends MockModule
{
	public function new( context : IApplicationContext )  
	{
		super( context );
	}
	
	override public function initialize( context : IApplicationContext ) : Void 
	{
		this.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "hello receiver" ] );
	}
}