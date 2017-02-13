package hex.util;

import hex.collection.ILocatorListener;
import hex.core.CoreFactoryVODef;
import hex.di.IDependencyInjector;
import hex.event.MessageType;
import hex.metadata.IAnnotationProvider;
import hex.runtime.basic.IRunTimeCoreFactory;
import hex.structures.Size;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class FastEvalTest
{
	var _coreFactory : IRunTimeCoreFactory;
	
	@Before
	public function setUp() : Void
	{
		this._coreFactory = new MockCoreFactory();
	}

	@After
	public function tearDown() : Void
	{
		this._coreFactory = null;
	}
	
	@Test( "test eval method" )
	public function testEvalMethod() : Void
	{
		var size = new Size( 10, 20 );
		var width = FastEval.fromTarget( size, "width", this._coreFactory );
		Assert.equals( size.width, width, "values should be the same" );
	}
}


private class MockCoreFactory implements IRunTimeCoreFactory
{
	public function new()
	{
		
	}
	
	public function getInjector() : IDependencyInjector
	{
		return null;
	}
	
	public function getAnnotationProvider() : IAnnotationProvider
	{
		return null;
	}
	
	public function clear() : Void
	{
		//
	}
	
	public function buildInstance( constructorVO : CoreFactoryVODef ) : Dynamic
	{
		return null;
	}
	
	public function fastEvalFromTarget( target : Dynamic, toEval : String ) : Dynamic
	{
		return null;
	}
	
	//
	public function keys() : Array<String>
	{
		return null;
	}
	
    public function values() : Array<Dynamic>
	{
		return null;
	}

    public function isRegisteredWithKey( key : String ) : Bool
	{
		return false;
	}

    public function locate( key : String ) : Dynamic
	{
		return null;
	}

    public function register( key : String, element : Dynamic ) : Bool
	{
		return false;
	}

    public function unregister( key : String ) : Bool
	{
		return false;
	}

    public function add( map : Map<String, Dynamic> ) : Void
	{
		//
	}
	
	public function addHandler( messageType : MessageType, callback : Dynamic ) : Bool
	{
		return false;
	}
	
	public function removeHandler( messageType : MessageType, callback : Dynamic ) : Bool
	{
		return false;
	}

    public function addListener( listener : ILocatorListener<String, Dynamic> ) : Bool
	{
		return false;
	}

    public function removeListener( listener : ILocatorListener<String, Dynamic> ) : Bool
	{
		return false;
	}
	
	public function addProxyFactoryMethod( className : String, socpe : Dynamic, factoryMethod : Dynamic ) : Void
	{
		//
	}
	
	public function removeProxyFactoryMethod( classPath : String ) : Bool
	{
		return false;
	}
	
	public function hasProxyFactoryMethod( className : String ) : Bool
	{
		return false;
	}
}