package hex.ioc.parser.xml.mock;

import hex.core.IApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class MockMessageParserModule extends MockModule implements IMockMessageParserModule
{
	public function new( context : IApplicationContext ) 
	{
		super( context );
	}
	
	public function parse( message : String ) : String
	{
		return message.toUpperCase();
	}
}