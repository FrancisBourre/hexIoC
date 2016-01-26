package hex.ioc.parser.xml.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockRectangleFactory
{
	function new() 
	{
		
	}
	
	static public function getRectangle( x : Float, y : Float, width : Float, height : Float ) : MockRectangle
	{
		return new MockRectangle( x, y, width, height );
	}
}