package hex.compiler.parser.xml.context;

import hex.domain.ApplicationDomainDispatcher;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.core.ICoreFactory;
import hex.ioc.parser.xml.context.mock.MockApplicationContext;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextBuildingTest
{
	var _applicationAssembler 		: ApplicationAssembler;
		
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
		return this._applicationAssembler.getApplicationContext( "applicationContext" ).getCoreFactory();
	}
	
	@Test( "test applicationContext building" )
	public function testApplicationContextBuilding() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/applicationContextBuildingTest.xml" );
		
		var applicationContext = this._applicationAssembler.getApplicationContext( "applicationContext" );
		Assert.isNotNull( applicationContext, "applicationContext shouldn't be null" );
		Assert.isInstanceOf( applicationContext, MockApplicationContext, "applicationContext shouldn't be an instance of 'MockApplicationContext'" );
		Assert.equals( "Hola Mundo", applicationContext.getCoreFactory().locate( "test" ), "String values should be the same" );
	}
}