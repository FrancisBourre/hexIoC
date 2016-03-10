package hex.ioc.parser.xml.context.mock;

import hex.ioc.assembler.ApplicationContext;
import hex.ioc.core.ICoreFactory;

/**
 * ...
 * @author Francis Bourre
 */
class MockApplicationContext extends ApplicationContext
{
	public function new( coreFactory : ICoreFactory, applicationContextName : String ) 
	{
		super( coreFactory, applicationContextName );
	}
}