package hex.ioc.parser.xml.assembler;

import hex.domain.ApplicationDomainDispatcher;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.assembler.IApplicationAssembler;
import hex.ioc.core.BuilderFactory;
import hex.ioc.parser.xml.assembler.mock.MockStateCommand;
import hex.ioc.parser.xml.assembler.mock.MockStateCommandWithModule;
import hex.ioc.parser.xml.assembler.mock.MockModule;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationAssemblerStateTest
{
	private var _contextParser 				: ApplicationXMLParser;
	private var _builderFactory 			: BuilderFactory;
	private var _applicationAssembler 		: IApplicationAssembler;
		
	@Before
	public function setUp() : Void
	{
		this._applicationAssembler 	= new ApplicationAssembler();
		this._builderFactory 		= this._applicationAssembler.getBuilderFactory( this._applicationAssembler.getApplicationContext( "applicationContext" ) );
	}

	@After
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.getInstance().clear();
		this._applicationAssembler.release();
	}
		
	private function _build( xml : Xml ) : Void
	{
		this._contextParser = new ApplicationXMLParser();
		this._contextParser.parse( this._applicationAssembler, xml );
		this._applicationAssembler.buildEverything();
	}
	
	@Test( "test building state transitions" )
	public function testBuildingStateTransitions() : Void
	{
		var source : String = '
		<root name="applicationContext">

			<state id="assemblingStart" static-ref="hex.ioc.assembler.ApplicationAssemblerState.ASSEMBLING_START">
				<enter command-class="hex.ioc.parser.xml.assembler.mock.MockStateCommand"/>
			</state>
			
			<state id="objectsBuilt" static-ref="hex.ioc.assembler.ApplicationAssemblerState.OBJECTS_BUILT">
				<enter command-class="hex.ioc.parser.xml.assembler.mock.MockStateCommandWithModule" fire-once="true" context-owner="module"/>
			</state>
			
			<state id="domainListenersAssigned" static-ref="hex.ioc.assembler.ApplicationAssemblerState.DOMAIN_LISTENERS_ASSIGNED">
				<enter command-class="hex.ioc.parser.xml.assembler.mock.MockStateCommand"/>
			</state>
			
			<state id="methodsCalled" static-ref="hex.ioc.assembler.ApplicationAssemblerState.METHODS_CALLED">
				<enter command-class="hex.ioc.parser.xml.assembler.mock.MockStateCommand"/>
			</state>
			
			<state id="modulesInitialized" static-ref="hex.ioc.assembler.ApplicationAssemblerState.MODULES_INITIALIZED">
				<enter command-class="hex.ioc.parser.xml.assembler.mock.MockStateCommand"/>
			</state>
			
			<state id="assemblingEnd" static-ref="hex.ioc.assembler.ApplicationAssemblerState.ASSEMBLING_END">
				<enter command-class="hex.ioc.parser.xml.assembler.mock.MockStateCommandWithModule" fire-once="true" context-owner="anotherModule"/>
			</state>
			
			<module id="module" type="hex.ioc.parser.xml.assembler.mock.MockModule" map-type="hex.module.IModule"/>
			<module id="anotherModule" type="hex.ioc.parser.xml.assembler.mock.MockModule" map-type="hex.module.IModule"/>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );
	}
	
}