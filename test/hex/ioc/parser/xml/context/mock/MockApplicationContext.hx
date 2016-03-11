package hex.ioc.parser.xml.context.mock;

import hex.event.IDispatcher;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.core.ICoreFactory;

/**
 * ...
 * @author Francis Bourre
 */
class MockApplicationContext extends ApplicationContext
{
	public function new( dispatcher : IDispatcher<{}>, coreFactory : ICoreFactory, applicationContextName : String ) 
	{
		super( dispatcher, coreFactory, applicationContextName );
	}
}