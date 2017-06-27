package hex.ioc.parser.xml.context.mock;

import hex.ioc.assembler.ApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class MockApplicationContext extends ApplicationContext
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