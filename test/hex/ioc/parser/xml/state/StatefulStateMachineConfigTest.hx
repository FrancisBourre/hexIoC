package hex.ioc.parser.xml.state;

import hex.domain.ApplicationDomainDispatcher;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.core.IContextFactory;
import hex.ioc.parser.xml.state.mock.MockModuleWorkingWithStates;
import hex.ioc.parser.xml.state.mock.MockStateEnum;
import hex.state.State;
import hex.state.config.stateful.StatefulStateMachineConfig;
import hex.unittest.assertion.Assert;


/**
 * ...
 * @author Francis Bourre
 */
class StatefulStateMachineConfigTest
{
	var _builderFactory 			: IContextFactory;
	var _applicationAssembler 		: ApplicationAssembler;

	@After
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.getInstance().clear();
		this._applicationAssembler.release();
	}
	
	@Test( "test statemachine configuration" )
	public function testStateMachineConfiguration() : Void
	{
		this._applicationAssembler 	= XmlReader.readXmlFile( "context/statefulStateMachineConfigTest.xml" );
		this._builderFactory 		= this._applicationAssembler.getContextFactory( this._applicationAssembler.getApplicationContext( "applicationContext" ) );

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