package hex.ioc.core;

import hex.error.IllegalArgumentException;
import hex.structures.Point;
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
		Assert.assertEquals( CoreFactoryTest, this._coreFactory.getClassReference( "hex.ioc.core.CoreFactoryTest" ), "'getClassReference' should return the right class reference" );
		Assert.assertMethodCallThrows( IllegalArgumentException, this._coreFactory, this._coreFactory.getClassReference, ["dummy.unavailable.Class"], "'getClassReference' should throw IllegalArgumentException" );
	}
	
	@test( "Test getStaticReference" )
    public function testGetStaticReference() : Void
    {
		Assert.assertEquals( "static_ref", this._coreFactory.getStaticReference( "hex.ioc.core.CoreFactoryTest.STATIC_REF" ), "'getStaticReference' should return the right static property" );
		Assert.assertMethodCallThrows( IllegalArgumentException, this._coreFactory, this._coreFactory.getStaticReference, ["hex.ioc.core.CoreFactoryTest.UnavailableStaticRef"], "'getStaticReference' should throw IllegalArgumentException" );
	}
	
	@test( "Test buildInstance with arguments" )
    public function testBuildInstanceWithArguments() : Void
    {
		var p : Point = this._coreFactory.buildInstance( "hex.structures.Point", [2, 3] );
		Assert.failIsNull( p, "'p' should not be null" );
		Assert.assertEquals( 2, p.x, "'p.x' should return 2" );
		Assert.assertEquals( 3, p.y, "'p.x' should return 3" );
	}
}