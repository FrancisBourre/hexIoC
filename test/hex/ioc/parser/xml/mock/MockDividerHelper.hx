package hex.ioc.parser.xml.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockDividerHelper implements IMockDividerHelper
{
	public function new() 
	{
		
	}
	
	public function divide( target : Float, divider : Float ) : Float 
	{
		return target / divider;
	}
}