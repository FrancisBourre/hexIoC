package hex.ioc.parser.xml.context.mock;

import hex.ioc.assembler.ApplicationContext;
import hex.ioc.assembler.IApplicationAssembler;

/**
 * ...
 * @author Francis Bourre
 */
class MockApplicationContext extends ApplicationContext
{

	public function new( applicationAssembler : IApplicationAssembler, applicationContextName : String ) 
	{
		super( applicationAssembler, applicationContextName );
	}
}