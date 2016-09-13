package hex.ioc.core;

import hex.structures.Point;
import hex.structures.Size;

/**
 * ...
 * @author Francis Bourre
 */
class MockClassForCoreFactoryTest
{
	static var _Instance : MockClassForCoreFactoryTest = null;
	
	public static var instance = new MockClassForCoreFactoryTest();
	
	public function new() 
	{
		
	}
	
	static public function getInstance() : MockClassForCoreFactoryTest
	{
		if ( MockClassForCoreFactoryTest._Instance == null )
		{
			MockClassForCoreFactoryTest._Instance = new MockClassForCoreFactoryTest();
		}
		
		return MockClassForCoreFactoryTest._Instance;
	}
	
	public function getPoint( x : Int, y : Int ) : Point
	{
		return new Point( x, y );
	}
	
	static public function getSize( width : Float, height : Float ) : Size
	{
		return new Size( width, height );
	}
}