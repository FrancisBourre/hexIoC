package hex.ioc.parser.xml.state;

import hex.domain.ApplicationDomainDispatcher;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.assembler.IApplicationAssembler;
import hex.ioc.core.BuilderFactory;
import hex.ioc.parser.xml.state.mock.MockModuleWorkingWithStates;
import hex.ioc.parser.xml.state.mock.MockStateEnum;
import hex.ioc.parser.xml.XMLContextParser;
import hex.state.config.stateful.StatefulStateMachineConfig;
import hex.state.State;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class StatefulStateMachineConfigTest
{
	private var _contextParser 				: XMLContextParser;
	private var _applicationContext 		: ApplicationContext;
	private var _builderFactory 			: BuilderFactory;
	private var _applicationAssembler 		: IApplicationAssembler;
		
	@setUp
	public function setUp() : Void
	{
		this._applicationAssembler 	= new ApplicationAssembler();
		this._applicationContext 	= this._applicationAssembler.getApplicationContext( "applicationContext" );
		this._builderFactory 		= this._applicationAssembler.getBuilderFactory( this._applicationContext );
	}

	@tearDown
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.getInstance().clear();
		this._applicationAssembler.release();
	}
		
	private function _build( xml : Xml, applicationContext : ApplicationContext = null ) : Void
	{
		this._contextParser = new XMLContextParser();
		this._contextParser.setParserCollection( new XMLParserCollection() );
		this._contextParser.parse( applicationContext != null ? applicationContext : this._applicationContext, this._applicationAssembler, xml );
		this._applicationAssembler.buildEverything();
	}
	
	@test( "test statemachine configuration" )
	public function testStateMachineConfiguration() : Void
	{
		var source : String = '
		<root>

			<initialState id="initialState" static-ref="com.ioc.parser.xml.MockStateEnum.INITIAL_STATE">
				<method-call name="addTransition">
					<argument static-ref="hex.ioc.parser.xml.state.mock.MockStateMessage.TRIGGER_NEXT_STATE"/>
					<argument static-ref="com.ioc.parser.xml.MockStateEnum.NEXT_STATE"/>
				</method-call>

				<method-call name="addExitCommand">
					<argument type="Class" value="hex.ioc.parser.xml.state.mock.MockExitStateCommand"/>
					<argument ref="myModule"/>
				</method-call>

			</initialState>

			<stateConfig id="stateConfig" type="hex.state.config.stateful.StatefulStateMachineConfig">
				<argument ref="initialState"/>
			</stateConfig>

			<module id="myModule" type="com.ioc.parser.xml.MockModuleWorkingWithStates">
				<argument ref="stateConfig"/>
			</module>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );

		var initialState : State = this._builderFactory.getCoreFactory().locate( "initialState" );
		Assert.isNotNull( initialState, "state should not be null" );
		Assert.equals( MockStateEnum.INITIAL_STATE, initialState, "state should be the same" );

		var stateConfig : StatefulStateMachineConfig = this._builderFactory.getCoreFactory().locate( "stateConfig" );
		Assert.isNotNull( stateConfig, "config should not be null" );

		var myModule : MockModuleWorkingWithStates = this._builderFactory.getCoreFactory().locate( "myModule" );
		Assert.isNotNull( myModule, "module should not be null" );

		Assert.isTrue( myModule.commandWasCalled, "command should be called" );
	}
}