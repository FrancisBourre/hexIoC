package hex.mock;

import hex.ioc.assembler.ApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class MockIoCApplicationContext extends ApplicationContext
{
	public function new( applicationContextName : String ) 
	{
		super( applicationContextName );
	}
	
	public function getTest() : String
	{
		return 'test';
	}
}