package hex.ioc.parser.xml.context;

import hex.domain.ApplicationDomainDispatcher;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.assembler.IApplicationAssembler;
import hex.ioc.core.BuilderFactory;
import hex.ioc.parser.xml.context.mock.MockApplicationContext;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextBuildingTest
{
	private var _contextParser 				: ApplicationXMLParser;
	private var _applicationAssembler 		: IApplicationAssembler;
		
	@setUp
	public function setUp() : Void
	{
		this._applicationAssembler 	= new ApplicationAssembler();
	}

	@tearDown
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.getInstance().clear();
		this._applicationAssembler.release();
	}
		
	private function _build( xml : Xml ) : Void
	{
		this._contextParser = new ApplicationXMLParser();
		this._contextParser.setParserCollection( new XMLParserCollection() );
		this._contextParser.parse( this._applicationAssembler, xml );
		this._applicationAssembler.buildEverything();
	}
	
	@test( "test applicationContext building" )
	public function testApplicationContextBuilding() : Void
	{
		var source : String = '
		<root name="applicationContext" type="hex.ioc.parser.xml.context.mock.MockApplicationContext">

			<test id="test" value="Hola Mundo"/>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );
		
		var builderFactory :BuilderFactory = this._applicationAssembler.getBuilderFactory( this._applicationAssembler.getApplicationContext( "applicationContext" ) );
		
		var applicationContext : ApplicationContext = builderFactory.getCoreFactory().locate( "applicationContext" );
		Assert.isNotNull( applicationContext, "applicationContext shouldn't be null" );
		Assert.isInstanceOf( applicationContext, MockApplicationContext, "applicationContext shouldn't be an instance of 'MockApplicationContext'" );
		Assert.equals( "Hola Mundo", builderFactory.getCoreFactory().locate( "test" ), "String values should be the same" );
	}
}