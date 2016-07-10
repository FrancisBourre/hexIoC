package hex.util;

import hex.collection.ILocatorListener;
import hex.di.IDependencyInjector;
import hex.ioc.core.ICoreFactory;
import hex.ioc.parser.xml.mock.MockChatModule;
import hex.metadata.IAnnotationProvider;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class FastEvalTest
{
	var _coreFactory : ICoreFactory;
	
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
	
	/*@Test( "test eval method" )
	public function testEvalMethod() : Void
	{
		var chat = new MockChatModule();
		var f = FastEval.fromTarget( chat, "onTranslation", this._coreFactory );
		Assert.equals( f, chat.onTranslation, "methods should be the same" );
	}*/
}


private class MockCoreFactory implements ICoreFactory
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
	
	public function buildInstance( qualifiedClassName : String, ?args : Array<Dynamic>, ?factoryMethod : String, ?singletonAccess : String, ?instantiateUnmapped : Bool = false ) : Dynamic
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