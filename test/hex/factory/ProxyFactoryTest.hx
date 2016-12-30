package hex.factory;

import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ProxyFactoryTest
{
	var _proxy : ProxyFactory;
	
	@Before
	public function setUp() : Void
	{
		this._proxy = new ProxyFactory();
	}

	@After
	public function tearDown() : Void
	{
		
	}
	
	@Test
	public function testRegister() : Void
	{
		this._proxy.registerFactoryMethod( MockAssemblerVO, this._buildMockVO );
		var vo = new MockAssemblerVO();
		this._proxy.buildElement( MockAssemblerVO, vo );
		Assert.isTrue( vo.isConstructed );
	}
	
	function _buildMockVO( vo : MockAssemblerVO ) : Void
	{
		vo.isConstructed = true;
	}
}