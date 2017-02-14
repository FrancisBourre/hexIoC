package hex.ioc.parser.xml.assembler;

import hex.core.IApplicationAssembler;
import hex.domain.ApplicationDomainDispatcher;
import hex.event.MessageType;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.core.ContextFactory;
import hex.ioc.parser.xml.assembler.mock.MockApplicationContext;
import hex.ioc.parser.xml.assembler.mock.MockExitStateCommand;
import hex.ioc.parser.xml.assembler.mock.MockModule;
import hex.ioc.parser.xml.assembler.mock.MockStateCommand;
import hex.ioc.parser.xml.assembler.mock.MockStateCommandWithModule;
import hex.state.State;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationAssemblerStateTest
{
	var _contextFactory 			: ContextFactory;
	var _applicationAssembler 		: IApplicationAssembler;

	@After
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.getInstance().clear();
		if ( this._applicationAssembler != null )
		{
			this._applicationAssembler.release();
		}
		
		MockStateCommand.callCount 						= 0;
		MockStateCommand.lastInjecteContext 			= null;
		MockStateCommandWithModule.callCount 			= 0;
		MockStateCommandWithModule.lastInjectedModule 	= null;
	}
	
	@Test( "test building state transitions" )
	public function testBuildingStateTransitions() : Void
	{
		this._applicationAssembler = XmlReader.read( "context/testBuildingStateTransitions.xml" );
	}
	
	@Test( "test extending state transitions" )
	public function testExtendingStateTransitions() : Void
	{
		this._applicationAssembler = XmlReader.read( "context/testExtendingStateTransitions.xml" );
		
		var coreFactory = this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory();
		var module : MockModule = coreFactory.locate( "module" );
		var anotherModule : MockModule = coreFactory.locate( "anotherModule" );

		Assert.isNotNull( module, "'module' shouldn't be null" );
		Assert.isNotNull( anotherModule, "'anotherModule' shouldn't be null" );
		
		var applicationContext : MockApplicationContext = coreFactory.locate( "applicationContext" );
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
	
	@Test( "test custom state transition" )
	public function testCustomStateTransition() : Void
	{
		MockStateCommand.callCount = 0;
		MockExitStateCommand.callCount = 0;
		MockStateCommand.lastInjecteContext = null;
		
		this._applicationAssembler = XmlReader.read( "context/testCustomStateTransition.xml" );
		
		var context = this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext );
		var coreFactory = context.getCoreFactory();
		
		var module : MockModule = coreFactory.locate( "module" );
		Assert.isNotNull( module, "'module' shouldn't be null" );
		
		var messageType : MessageType = coreFactory.locate( "messageID" );
		var anotherMessageType : MessageType = coreFactory.locate( "anotherMessageID" );
		Assert.equals( 'messageName', messageType, "name property should be 'messageName'" );
		Assert.equals( 'anotherMessageName', anotherMessageType, "name property should be 'anotherMessageName'" );
		
		var customState : State = coreFactory.locate( "customState" );
		var anotherCustomState : State = coreFactory.locate( "anotherCustomState" );
		Assert.equals( 'customState', customState.getName(), "name property should be 'customState'" );
		Assert.equals( 'anotherCustomState', anotherCustomState.getName(), "name property should be 'anotherCustomState'" );

		var trigger = new MessageType( "test" );
		( cast context ).state.ASSEMBLING_END.addTransition( trigger, customState );
		
		context.dispatch( trigger );
		Assert.equals( 0, MockExitStateCommand.callCount, "'MockExitStateCommand' should not have been called" );
		

		Assert.equals( 0, MockStateCommand.callCount, "'MockStateCommand' should not have been called yet" );
		Assert.equals( 1, module.callbackCount, "module callback should be triggered once" );
		Assert.equals( customState, module.stateCallback, "states should be the same" );
		
		module.callbackCount = 0;
		context.dispatch( messageType );
		Assert.equals( 1, MockStateCommand.callCount, "'MockStateCommand' should have been called once" );
		Assert.equals( 0, module.callbackCount, "module callback should not be triggered" );
		
		MockStateCommand.callCount = 0;
		context.dispatch( anotherMessageType );
		Assert.equals( 1, module.callbackCount, "module callback should be triggered once again" );
		Assert.equals( 0, MockStateCommand.callCount, "'MockStateCommand' should not have been called this time" );
		Assert.equals( 1, MockExitStateCommand.callCount, "'MockExitStateCommand' should have been called" );
	}
}