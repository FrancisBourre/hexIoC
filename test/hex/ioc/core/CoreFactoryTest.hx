package hex.ioc.core;

import hex.error.IllegalArgumentException;
import hex.structures.Point;
import hex.structures.Size;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class CoreFactoryTest
{
	public static inline var STATIC_REF : String = "static_ref";
	
	private var _coreFactory : CoreFactory;

    @setUp
    public function setUp() : Void
    {
        this._coreFactory = new CoreFactory();
    }

    @tearDown
    public function tearDown() : Void
    {
        this._coreFactory = null;
    }
	
	@test( "Test getClassReference" )
    public function testGetClassReference() : Void
    {
		Assert.equals( CoreFactoryTest, this._coreFactory.getClassReference( "hex.ioc.core.CoreFactoryTest" ), "'getClassReference' should return the right class reference" );
		Assert.methodCallThrows( IllegalArgumentException, this._coreFactory, this._coreFactory.getClassReference, ["dummy.unavailable.Class"], "'getClassReference' should throw IllegalArgumentException" );
	}
	
	@test( "Test getStaticReference" )
    public function testGetStaticReference() : Void
    {
		Assert.equals( "static_ref", this._coreFactory.getStaticReference( "hex.ioc.core.CoreFactoryTest.STATIC_REF" ), "'getStaticReference' should return the right static property" );
		Assert.methodCallThrows( IllegalArgumentException, this._coreFactory, this._coreFactory.getStaticReference, ["hex.ioc.core.CoreFactoryTest.UnavailableStaticRef"], "'getStaticReference' should throw IllegalArgumentException" );
	}
	
	@test( "Test buildInstance with arguments" )
    public function testBuildInstanceWithArguments() : Void
    {
		var p : Point = this._coreFactory.buildInstance( "hex.structures.Point", [2, 3] );
		Assert.isNotNull( p, "'p' should not be null" );
		Assert.equals( 2, p.x, "'p.x' should return 2" );
		Assert.equals( 3, p.y, "'p.x' should return 3" );
	}
	
	@test( "Test buildInstance with singleton access" )
    public function testBuildInstanceWithSingletonAccess() : Void
    {
		var instance : MockClassForCoreFactoryTest = this._coreFactory.buildInstance( "hex.ioc.core.MockClassForCoreFactoryTest", null, null, "getInstance" );
		Assert.isInstanceOf( instance, MockClassForCoreFactoryTest, "should be instance of 'MockClassForCoreFactoryTest'" );
	}
	
	@test( "Test buildInstance with factory access" )
    public function testBuildInstanceWithFactoryAccess() : Void
    {
		var size : Size = this._coreFactory.buildInstance( "hex.ioc.core.MockClassForCoreFactoryTest", [20, 30], "getSize", null );
		Assert.isNotNull( size, "'size' should not be null" );
		Assert.equals( 20, size.width, "'size.width' should return 20" );
		Assert.equals( 30, size.height, "'size.height' should return 30" );
	}
	
	@test( "Test buildInstance with factory and singleton access" )
    public function testBuildInstanceWithFactoryAndSingletonAccess() : Void
    {
		var p : Point = this._coreFactory.buildInstance( "hex.ioc.core.MockClassForCoreFactoryTest", [2, 3], "getPoint", "getInstance" );
		Assert.isNotNull( p, "'p' should not be null" );
		Assert.equals( 2, p.x, "'p.x' should return 2" );
		Assert.equals( 3, p.y, "'p.x' should return 3" );
	}
}