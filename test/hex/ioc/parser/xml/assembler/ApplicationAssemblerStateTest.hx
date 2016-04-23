package hex.ioc.parser.xml.assembler;

import hex.domain.ApplicationDomainDispatcher;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.core.IContextFactory;
import hex.ioc.parser.xml.assembler.mock.MockApplicationContext;
import hex.ioc.parser.xml.assembler.mock.MockModule;
import hex.ioc.parser.xml.assembler.mock.MockStateCommand;
import hex.ioc.parser.xml.assembler.mock.MockStateCommandWithModule;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationAssemblerStateTest
{
	var _contextParser 				: ApplicationXMLParser;
	var _builderFactory 			: IContextFactory;
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
		
		MockStateCommand.callCount 						= 0;
		MockStateCommand.lastInjecteContext 			= null;
		MockStateCommandWithModule.callCount 			= 0;
		MockStateCommandWithModule.lastInjectedModule 	= null;
	}
		
	function _build( xml : Xml ) : Void
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

			<state id="assemblingStart" ref="applicationContext.state.ASSEMBLING_START">
				<enter command-class="hex.ioc.parser.xml.assembler.mock.MockStateCommand"/>
			</state>
			
			<state id="objectsBuilt" ref="applicationContext.state.OBJECTS_BUILT">
				<enter command-class="hex.ioc.parser.xml.assembler.mock.MockStateCommandWithModule" fire-once="true" context-owner="module"/>
			</state>
			
			<state id="domainListenersAssigned" ref="applicationContext.state.DOMAIN_LISTENERS_ASSIGNED">
				<enter command-class="hex.ioc.parser.xml.assembler.mock.MockStateCommand"/>
			</state>
			
			<state id="methodsCalled" ref="applicationContext.state.METHODS_CALLED">
				<enter command-class="hex.ioc.parser.xml.assembler.mock.MockStateCommand"/>
			</state>
			
			<state id="modulesInitialized" ref="applicationContext.state.MODULES_INITIALIZED">
				<enter command-class="hex.ioc.parser.xml.assembler.mock.MockStateCommand"/>
			</state>
			
			<state id="assemblingEnd" ref="applicationContext.state.ASSEMBLING_END">
				<enter command-class="hex.ioc.parser.xml.assembler.mock.MockStateCommandWithModule" fire-once="true" context-owner="anotherModule"/>
			</state>
			
			<module id="module" type="hex.ioc.parser.xml.assembler.mock.MockModule" map-type="hex.module.IModule"/>
			<module id="anotherModule" type="hex.ioc.parser.xml.assembler.mock.MockModule" map-type="hex.module.IModule"/>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );
		
		this._builderFactory = this._applicationAssembler.getContextFactory( this._applicationAssembler.getApplicationContext( "applicationContext" ) );
	}
	
	@Test( "test extending state transitions" )
	public function testExtendingStateTransitions() : Void
	{
		var source : String = '
		<root name="applicationContext" type="hex.ioc.parser.xml.assembler.mock.MockApplicationContext">

			<state id="customState" ref="applicationContext.state.CUSTOM_STATE">
				<enter command-class="hex.ioc.parser.xml.assembler.mock.MockStateCommandWithModule" context-owner="anotherModule"/>
			</state>
			
			<state id="anotherState" ref="applicationContext.state.ANOTHER_STATE">
				<enter command-class="hex.ioc.parser.xml.assembler.mock.MockStateCommand" fire-once="true"/>
			</state>
			
			<module id="module" type="hex.ioc.parser.xml.assembler.mock.MockModule" map-type="hex.module.IModule"/>
			<module id="anotherModule" type="hex.ioc.parser.xml.assembler.mock.MockModule" map-type="hex.module.IModule"/>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );
		
		var builderFactory : IContextFactory = this._applicationAssembler.getContextFactory( this._applicationAssembler.getApplicationContext( "applicationContext" ) );
		var coreFactory = builderFactory.getCoreFactory();
		var module : MockModule = coreFactory.locate( "module" );
		var anotherModule : MockModule = coreFactory.locate( "anotherModule" );

		Assert.isNotNull( module, "'module' shouldn't be null" );
		Assert.isNotNull( anotherModule, "'anotherModule' shouldn't be null" );
		
		var applicationContext : MockApplicationContext = builderFactory.getCoreFactory().locate( "applicationContext" );
		Assert.isNotNull( applicationContext, "applicationContext shouldn't be null" );
		Assert.isInstanceOf( applicationContext, MockApplicationContext, "applicationContext shouldn't be an instance of 'MockApplicationContext'" );

		Assert.isNotNull( ( cast applicationContext.state).CUSTOM_STATE, "CUSTOM_STATE shouldn't be null" );
		
		applicationContext.fireApplicationInit();
		Assert.equals( 1, MockStateCommandWithModule.callCount, "'MockStateCommandWithModule' should have been called once" );
		Assert.equals( anotherModule, MockStateCommandWithModule.lastInjectedModule, "module should be the same" );
		
		applicationContext.fireSwitchState();
		Assert.equals( 1, MockStateCommand.callCount, "'MockStateCommand' should have been called once" );
		Assert.equals( applicationContext, MockStateCommand.lastInjecteContext, "applicationContext should be the same" );
		
		MockStateCommandWithModule.lastInjectedModule = null;
		applicationContext.fireSwitchBack();
		Assert.equals( 2, MockStateCommandWithModule.callCount, "'MockStateCommandWithModule' should have been called twice" );
		Assert.equals( anotherModule, MockStateCommandWithModule.lastInjectedModule, "module should be the same" );
		
		applicationContext.fireSwitchState();
		MockStateCommand.lastInjecteContext = null;
		Assert.equals( 1, MockStateCommand.callCount, "'MockStateCommand' should have been called once" );
		Assert.isNull( MockStateCommand.lastInjecteContext, "applicationContext should be null" );
	}
}