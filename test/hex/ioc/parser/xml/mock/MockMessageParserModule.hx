package hex.ioc.parser.xml.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockMessageParserModule extends MockModule implements IMockMessageParserModule
{
	public function new() 
	{
		super();
	}
	
	public function parse( message : String ) : String
	{
		return message.toUpperCase();
	}
}