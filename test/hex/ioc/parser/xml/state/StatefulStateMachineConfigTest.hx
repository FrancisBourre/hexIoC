package hex.ioc.parser.xml.state;

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
	@Test( "test statemachine configuration" )
	public function testStateMachineConfiguration() : Void
	{
		var assembler = XmlReader.readXmlFile( "context/statefulStateMachineConfigTest.xml" );
		var factory	= assembler.getApplicationContext( "applicationContext" ).getCoreFactory();

		var initialState : State = factory.locate( "initialState" );
		Assert.isNotNull( initialState, "state should not be null" );
		Assert.equals( MockStateEnum.INITIAL_STATE, initialState, "state should be the same" );

		var stateConfig : StatefulStateMachineConfig = factory.locate( "stateConfig" );
		Assert.isNotNull( stateConfig, "config should not be null" );

		var myModule : MockModuleWorkingWithStates = factory.locate( "myModule" );
		Assert.isNotNull( myModule, "module should not be null" );

		Assert.isTrue( myModule.commandWasCalled, "command should be called" );
	}
}