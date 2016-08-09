package hex.ioc.parser.xml.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockDocument
{
	public function new() 
	{
		
	}
	
	public function querySelector( query : String ) : MockDocument
	{
		return query == "#test" ? this : null;
	}
}