package hex.compiler.parser.xml;

import hex.domain.ApplicationDomainDispatcher;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.core.IContextFactory;
import hex.ioc.parser.xml.ApplicationXMLParser;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class XmlCompilerTest
{
	var _contextParser 				: ApplicationXMLParser;
	var _applicationContext 		: AbstractApplicationContext;
	var _contextFactory 			: IContextFactory;
	var _applicationAssembler 		: ApplicationAssembler;

	@Before
	public function setUp() : Void
	{

	}

	@After
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.getInstance().clear();
		this._applicationAssembler.release();
	}
	
	@Test( "test building String" )
	public function testBuildingString() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/testBuildingString.xml" );
		var s : String = this._applicationAssembler.getApplicationContext( "applicationContext" ).getCoreFactory().locate( "s" );
		Assert.equals( "hello", s, "" );
	}
	
}