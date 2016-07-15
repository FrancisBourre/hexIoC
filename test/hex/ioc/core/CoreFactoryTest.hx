package hex.ioc.core;

import hex.MockDependencyInjector;
import hex.collection.ILocatorListener;
import hex.di.IDependencyInjector;
import hex.di.annotation.IAnnotationDataProvider;
import hex.di.annotation.InjectorClassVO;
import hex.error.IllegalArgumentException;
import hex.event.IEvent;
import hex.metadata.IAnnotationProvider;
import hex.structures.Point;
import hex.structures.PointFactory;
import hex.structures.Size;
import hex.unittest.assertion.Assert;
import hex.util.ClassUtil;

/**
 * ...
 * @author Francis Bourre
 */
class CoreFactoryTest
{
	var _coreFactory : CoreFactory;

    @Before
    public function setUp() : Void
    {
        this._coreFactory = new CoreFactory( new MockDependencyInjector(), new MockAnnotationDataProvider() );
    }

    @After
    public function tearDown() : Void
    {
        this._coreFactory = null;
    }
	
	@Test( "Test register" )
    public function testRegister() : Void
    {
		var listener = new MockCoreFactoryListener();
		this._coreFactory.addListener( listener );
		
		var value = new MockValue();
		Assert.isFalse( this._coreFactory.isRegisteredWithKey( "key" ),  "'isRegisteredWithKey' should return false" );
		Assert.isFalse( this._coreFactory.isInstanceRegistered( value ),  "'isInstanceRegistered' should return false" );
		
		Assert.isTrue( this._coreFactory.register( "key", value ),  "'register' should return true" );
		Assert.equals( 1, listener.registerEventCount, "listener should have received a register event" );
		Assert.equals( "key", listener.lastRegisterKeyReceived, "event key should be the same" );
		Assert.equals( value, listener.lastRegisterValueReceived, "event value should be the same" );
		Assert.equals( 0, listener.unregisterEventCount, "listener should not have received an unregister event" );
		
		Assert.isTrue( this._coreFactory.isRegisteredWithKey( "key" ),  "'isRegisteredWithKey' should return true" );
		Assert.isTrue( this._coreFactory.isInstanceRegistered( value ),  "'isInstanceRegistered' should return true" );
		Assert.methodCallThrows( IllegalArgumentException, this._coreFactory, this._coreFactory.register, [ "key", new MockValue() ],  "'register' should throw IllegalArgumentException when used twice with the same key" );
	}
	
	@Test( "Test unregisterWithKey" )
    public function testUnregisterWithKey() : Void
    {
		var listener = new MockCoreFactoryListener();
		this._coreFactory.addListener( listener );
		
		var value = new MockValue();
		this._coreFactory.register( "key", value );
		listener.registerEventCount = 0;
		
		Assert.isTrue( this._coreFactory.unregisterWithKey( "key" ), "'unregisterWithKey' should return true" );
		
		Assert.equals( 1, listener.unregisterEventCount, "listener should have received an unregister event" );
		Assert.equals( "key", listener.lastRegisterKeyReceived, "event key should be the same" );
		Assert.equals( value, listener.lastRegisterValueReceived, "event value should be the same" );
		Assert.equals( 0, listener.registerEventCount, "listener should not have received a register event" );
		
		Assert.isFalse( this._coreFactory.isRegisteredWithKey( "key" ),  "'isRegisteredWithKey' should return false" );
		Assert.isFalse( this._coreFactory.isInstanceRegistered( value ),  "'isInstanceRegistered' should return false" );
		Assert.isFalse( this._coreFactory.unregisterWithKey( "key" ), "'unregisterWithKey' should return false" );
	}
	
	@Test( "Test unregister" )
    public function testUnregister() : Void
    {
		var listener = new MockCoreFactoryListener();
		this._coreFactory.addListener( listener );
		
		var value = new MockValue();
		this._coreFactory.register( "key", value );
		listener.registerEventCount = 0;
		
		Assert.isTrue( this._coreFactory.unregister( value ), "'unregister' should return true" );
		
		Assert.equals( 1, listener.unregisterEventCount, "listener should have received an unregister event" );
		Assert.equals( "key", listener.lastRegisterKeyReceived, "event key should be the same" );
		Assert.equals( value, listener.lastRegisterValueReceived, "event value should be the same" );
		Assert.equals( 0, listener.registerEventCount, "listener should not have received a register event" );
		
		Assert.isFalse( this._coreFactory.isRegisteredWithKey( "key" ),  "'isRegisteredWithKey' should return false" );
		Assert.isFalse( this._coreFactory.isInstanceRegistered( value ),  "'isInstanceRegistered' should return false" );
		Assert.isFalse( this._coreFactory.unregister( value ), "'unregister' should return false" );
	}
	
	@Test( "Test getKeyOfInstance" )
    public function testGetKeyOfInstance() : Void
    {
		Assert.isNull( this._coreFactory.getKeyOfInstance( "key" ), "'getKeyOfInstance' should return null" );
		var value = new MockValue();
		this._coreFactory.register( "key", value );
		Assert.equals( "key", this._coreFactory.getKeyOfInstance( value ), "'getKeyOfInstance' should return value associated to the key" );
	}

	@Test( "Test buildInstance with arguments" )
    public function testBuildInstanceWithArguments() : Void
    {
		var size : Size = this._coreFactory.buildInstance( "hex.structures.Size", [2, 3] );
		Assert.isNotNull( size, "'size' should not be null" );
		Assert.equals( 2, size.width, "'size.width' should return 2" );
		Assert.equals( 3, size.height, "'size.height' should return 3" );
	}
	
	@Test( "Test buildInstance with singleton access" )
    public function testBuildInstanceWithSingletonAccess() : Void
    {
		var instance : MockClassForCoreFactoryTest = this._coreFactory.buildInstance( "hex.ioc.core.MockClassForCoreFactoryTest", null, null, "getInstance" );
		Assert.isInstanceOf( instance, MockClassForCoreFactoryTest, "should be instance of 'MockClassForCoreFactoryTest'" );
	}
	
	@Test( "Test buildInstance with factory access" )
    public function testBuildInstanceWithFactoryAccess() : Void
    {
		var size : Size = this._coreFactory.buildInstance( "hex.ioc.core.MockClassForCoreFactoryTest", [ 20.0, 30.0 ], "getSize", null );
		Assert.isNotNull( size, "'size' should not be null" );
		Assert.equals( 20.0, size.width, "'size.width' should return 20.0" );
		Assert.equals( 30.0, size.height, "'size.height' should return 30.0" );
	}
	
	@Test( "Test buildInstance with factory and singleton access" )
    public function testBuildInstanceWithFactoryAndSingletonAccess() : Void
    {
		var p : Point = this._coreFactory.buildInstance( "hex.ioc.core.MockClassForCoreFactoryTest", [2, 3], "getPoint", "getInstance" );
		Assert.isNotNull( p, "'p' should not be null" );
		Assert.equals( 2, p.x, "'p.x' should return 2" );
		Assert.equals( 3, p.y, "'p.x' should return 3" );
	}
	
	@Test( "Test buildInstance with injector" )
    public function testBuildInstanceWithInjector() : Void
    {
		var instance = this._coreFactory.buildInstance( "hex.ioc.core.MockClassForCoreFactoryTest", null, null, null, true );
		Assert.isInstanceOf( instance, MockClassForCoreFactoryTest, "should be instance of 'MockClassForCoreFactoryTest'" );
	}
	
	@Test( "Test proxy factory method" )
    public function testProxyFactoryMethod() : Void
    {
		var factory = new SizeFactory();
		Assert.isFalse( this._coreFactory.removeProxyFactoryMethod( "hex.structures.Point" ), "'removeProxyFactoryMethod' should return false" );
		Assert.isFalse( this._coreFactory.hasProxyFactoryMethod( "hex.structures.Point" ), "'hasProxyFactoryMethod' should return false" );
		
		this._coreFactory.addProxyFactoryMethod( "hex.structures.Point", factory, factory.build );
		Assert.isTrue( this._coreFactory.hasProxyFactoryMethod( "hex.structures.Point" ), "'hasProxyFactoryMethod' should return true after class name has been registered" );
		
		var size = this._coreFactory.buildInstance( "hex.structures.Point", [ 20.0, 30.0 ] );
		Assert.isInstanceOf( size, Size, "should be instance of 'hex.structures.Size'" );
		Assert.equals( 20.0, size.width, "'size.width' should return 20.0" );
		Assert.equals( 30.0, size.height, "'size.height' should return 30.0" );
		
		Assert.isTrue( this._coreFactory.removeProxyFactoryMethod( "hex.structures.Point" ), "'removeProxyFactoryMethod' should return true" );
		Assert.methodCallThrows( IllegalArgumentException,  this._coreFactory, this._coreFactory.buildInstance, [ "hex.structures.Point", [ 20, 30 ] ], "'buildInstance' should throw an exception because this class is not available" );
	}
	
	@Test( "Test static proxy factory method" )
    public function testStaticProxyFactoryMethod() : Void
    {
		Assert.isFalse( this._coreFactory.removeProxyFactoryMethod( "hex.structures.Size" ), "'removeProxyFactoryMethod' should return false" );
		Assert.isFalse( this._coreFactory.hasProxyFactoryMethod( "hex.structures.Size" ), "'hasProxyFactoryMethod' should return false" );
		
		this._coreFactory.addProxyFactoryMethod( "hex.structures.Size", PointFactory, PointFactory.build );
		Assert.isTrue( this._coreFactory.hasProxyFactoryMethod( "hex.structures.Size" ), "'hasProxyFactoryMethod' should return true after class name has been registered" );
		
		var p = this._coreFactory.buildInstance( "hex.structures.Size", [ 20, 30 ] );
		Assert.equals( 20, p.x, "'size.x' should return 20" );
		Assert.equals( 30, p.y, "'size.y' should return 30" );
		
		Assert.isTrue( this._coreFactory.removeProxyFactoryMethod( "hex.structures.Size" ), "'removeProxyFactoryMethod' should return true" );
		var size = this._coreFactory.buildInstance( "hex.structures.Size", [ 20.0, 30.0 ] );
		Assert.isInstanceOf( size, Size, "should be instance of 'hex.structures.Size'" );
		Assert.equals( 20.0, size.width, "'size.width' should return 20.0" );
		Assert.equals( 30.0, size.height, "'size.height' should return 30.0" );
	}
}

private class SizeFactory
{
	public function new()
	{
		
	}
	
	public function build( width : Float = 0, height : Float = 0 ) : Size
	{
		return new Size( width, height );
	}
}

private class MockValue
{
	public function new()
	{
		
	}
}

private class MockCoreFactoryListener implements ILocatorListener<String, Dynamic>
{
	public var lastRegisterKeyReceived			: String;
	public var lastRegisterValueReceived		: Dynamic;
	public var registerEventCount				: Int = 0;
	public var lastUnregisterKeyReceived		: String;
	public var unregisterEventCount				: Int = 0;
	
	public function new ()
	{
		
	}
	
	public function onRegister( key : String, value : Dynamic ) : Void 
	{
		this.lastRegisterKeyReceived 	= key;
		this.lastRegisterValueReceived 	= value;
		this.registerEventCount++;
	}
	
	public function onUnregister( key : String ) : Void 
	{
		this.lastUnregisterKeyReceived = key;
		this.unregisterEventCount++;
	}
	
	public function handleEvent( e : IEvent ) : Void 
	{
		
	}
}

private class MockAnnotationDataProvider implements IAnnotationProvider
{
	public function new()
	{
		
	}
	
	public function registerMetaData( metaDataName : String, scope : Dynamic, providerMethod : String->Dynamic ) : Void
	{
		
	}
	
	public function clear() : Void 
	{
		
	}
	
	public function parse( object : {} ) : Void 
	{
		
	}
	
	public function registerInjector( injector : IDependencyInjector ) : Void 
	{
		
	}
	
	public function unregisterInjector( injector : IDependencyInjector ) : Void 
	{
		
	}
}