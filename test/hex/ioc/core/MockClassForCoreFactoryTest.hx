package hex.ioc.core;

import hex.structures.Point;
import hex.structures.Size;

/**
 * ...
 * @author Francis Bourre
 */
class MockClassForCoreFactoryTest
{
	static private var _Instance : MockClassForCoreFactoryTest = null;
	
	private function new() 
	{
		
	}
	
	static public function getInstance() : MockClassForCoreFactoryTest
	{
		if ( MockClassForCoreFactoryTest._Instance == null )
		{
			MockClassForCoreFactoryTest._Instance = new MockClassForCoreFactoryTest();
		}
		
		return MockServiceProvider._Instance;
	}
	
	public function getPoint( x : Float, y : Float ) : Point
	{
		return new Point( x, y );
	}
	
	static public function getSize( width : Float, height : Float ) : Size
	{
		return new Size( width, height );
	}
}