package hex.compiler.parser.flow.context;

import hex.compiler.parser.flow.FlowCompiler;
import hex.core.IApplicationAssembler;
import hex.core.ICoreFactory;
import hex.domain.ApplicationDomainDispatcher;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.parser.xml.context.mock.MockApplicationContext;
import hex.runtime.ApplicationAssembler;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextBuildingTest
{
	var _applicationAssembler : IApplicationAssembler;
		
	@Before
	public function setUp() : Void
	{
		this._applicationAssembler 	= new ApplicationAssembler();
	}

	@After
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.getInstance().clear();
		this._applicationAssembler.release();
	}
		
	function _getCoreFactory() : ICoreFactory
	{
		return this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory();
	}
	
	@Test( "test applicationContext building" )
	public function testApplicationContextBuilding() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/extendApplicationContextTest.flow" );

		var applicationContext = this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext );
		Assert.isNotNull( applicationContext, "applicationContext shouldn't be null" );
		Assert.isInstanceOf( applicationContext, MockApplicationContext, "applicationContext shouldn't be an instance of 'MockApplicationContext'" );
		Assert.equals( "Hola Mundo", applicationContext.getCoreFactory().locate( "test" ), "String values should be the same" );
	}
}