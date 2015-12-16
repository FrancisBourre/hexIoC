package hex.ioc.parser.xml.mock;

import hex.structures.Point;

/**
 * ...
 * @author Francis Bourre
 */
class MockPointFactory
{
	private function new() 
	{
		
	}
	
	public function getPoint( x : Int, y : Int ) : Point
	{
		return new Point( x, y );
	}

	static private var _Instance : MockPointFactory = null;

	static public function getInstance() : MockPointFactory
	{
		if ( MockPointFactory._Instance == null )
		{
			MockPointFactory._Instance = new MockPointFactory();
		}
		
		return MockPointFactory._Instance;
	}
}