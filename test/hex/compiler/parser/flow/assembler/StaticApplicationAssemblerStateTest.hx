package hex.compiler.parser.flow.assembler;

import hex.core.IApplicationAssembler;
import hex.core.ICoreFactory;
import hex.domain.ApplicationDomainDispatcher;
import hex.event.MessageType;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.core.ContextFactory;
import hex.ioc.parser.xml.assembler.mock.MockApplicationContext;
import hex.ioc.parser.xml.assembler.mock.MockExitStateCommand;
import hex.ioc.parser.xml.assembler.mock.MockModule;
import hex.ioc.parser.xml.assembler.mock.MockStateCommand;
import hex.ioc.parser.xml.assembler.mock.MockStateCommandWithModule;
import hex.runtime.ApplicationAssembler;
import hex.state.State;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class StaticApplicationAssemblerStateTest
{
	var _builderFactory 			: ContextFactory;
	var _applicationAssembler 		: IApplicationAssembler;
		
	@Before
	public function setUp() : Void
	{
		this._applicationAssembler 	= new ApplicationAssembler();
	}

	@After
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.release();
		this._applicationAssembler.release();
		
		MockStateCommand.callCount 						= 0;
		MockStateCommand.lastInjectedContext			= null;
		MockStateCommandWithModule.callCount 			= 0;
		MockStateCommandWithModule.lastInjectedModule 	= null;
	}
		
	function _getCoreFactory() : ICoreFactory
	{
		return this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory();
	}
	
	@Test( "test building state transitions" )
	public function testBuildingStateTransitions() : Void
	{
		MockStateCommand.callCount = 0;
		MockStateCommand.lastInjectedContext = null;
		
		var code = StaticFlowCompiler.compile( this._applicationAssembler, "context/flow/testBuildingStateTransitions.flow", "StaticFlowCompiler_testBuildingStateTransitions" );
		code.execute();

		Assert.equals( code.applicationContext.state.ASSEMBLING_END, code.applicationContext.getCurrentState() );
		Assert.equals( 11, MockStateCommand.callCount );
		Assert.equals( code.applicationContext, MockStateCommand.lastInjectedContext, "applicationContext should be the same" );
	}
	
	@Test( "test extending state transitions" )
	public function testExtendingStateTransitions() : Void
	{
		MockStateCommand.callCount = 0;
		MockStateCommand.lastInjectedContext = null;
		
		var code = StaticFlowCompiler.compile( this._applicationAssembler, "context/flow/testExtendingStateTransitions.flow", "StaticFlowCompiler_testExtendingStateTransitions" );
		code.execute();
		
		var module : MockModule = code.locator.module;
		var anotherModule : MockModule = code.locator.anotherModule;

		Assert.isNotNull( module, "'module' shouldn't be null" );
		Assert.isNotNull( anotherModule, "'anotherModule' shouldn't be null" );
		
		Assert.isNotNull( code.applicationContext, "applicationContext shouldn't be null" );
		Assert.isInstanceOf( code.applicationContext, MockApplicationContext, "applicationContext shouldn't be an instance of 'MockApplicationContext'" );

		Assert.isNotNull( ( cast code.applicationContext.state).CUSTOM_STATE, "CUSTOM_STATE shouldn't be null" );
		
		code.applicationContext.fireApplicationInit();
		Assert.equals( 1, MockStateCommandWithModule.callCount, "'MockStateCommandWithModule' should have been called once" );
		Assert.equals( anotherModule, MockStateCommandWithModule.lastInjectedModule, "module should be the same" );
		
		code.applicationContext.fireSwitchState();
		Assert.equals( 1, MockStateCommand.callCount, "'MockStateCommand' should have been called once" );
		Assert.equals( code.applicationContext, MockStateCommand.lastInjectedContext, "applicationContext should be the same" );
		
		MockStateCommandWithModule.lastInjectedModule = null;
		code.applicationContext.fireSwitchBack();
		Assert.equals( 2, MockStateCommandWithModule.callCount, "'MockStateCommandWithModule' should have been called twice" );
		Assert.equals( anotherModule, MockStateCommandWithModule.lastInjectedModule, "module should be the same" );
		
		code.applicationContext.fireSwitchState();
		MockStateCommand.lastInjectedContext = null;
		Assert.equals( 1, MockStateCommand.callCount, "'MockStateCommand' should have been called once" );
		Assert.isNull( MockStateCommand.lastInjectedContext, "applicationContext should be null" );
	}
	
	@Test( "test custom state transition" )
	public function testCustomStateTransition() : Void
	{
		MockStateCommand.callCount = 0;
		MockExitStateCommand.callCount = 0;
		MockStateCommand.lastInjectedContext = null;
		
		var code = StaticFlowCompiler.compile( this._applicationAssembler, "context/flow/testCustomStateTransition.flow", "StaticFlowCompiler_testCustomStateTransition" );
		code.execute();
		
		var module : MockModule = code.locator.module;
		Assert.isNotNull( module, "'module' shouldn't be null" );
		
		var messageType : MessageType = code.locator.messageID;
		var anotherMessageType = code.locator.anotherMessageID;
		Assert.equals( 'messageName', messageType, "name property should be 'messageName'" );
		Assert.equals( 'anotherMessageName', anotherMessageType, "name property should be 'anotherMessageName'" );
		
		var customState : State = code.locator.customState;
		var anotherCustomState : State = code.locator.anotherCustomState;
		Assert.equals( 'customState', customState.getName(), "name property should be 'customState'" );
		Assert.equals( 'anotherCustomState', anotherCustomState.getName(), "name property should be 'anotherCustomState'" );
		
		var trigger = new MessageType( "test" );
		code.applicationContext.state.ASSEMBLING_END.addTransition( trigger, customState );
	
		code.applicationContext.dispatch( trigger );
		Assert.equals( 0, MockExitStateCommand.callCount, "'MockExitStateCommand' should not have been called" );
		
		Assert.equals( 0, MockStateCommand.callCount, "'MockStateCommand' should not have been called yet" );
		Assert.equals( 1, module.callbackCount, "module callback should be triggered once" );
		Assert.equals( customState, module.stateCallback, "states should be the same" );
		
		module.callbackCount = 0;
		code.applicationContext.dispatch( messageType );
		Assert.equals( 1, MockStateCommand.callCount, "'MockStateCommand' should have been called once" );
		Assert.equals( 0, module.callbackCount, "module callback should not be triggered" );
		
		MockStateCommand.callCount = 0;
		code.applicationContext.dispatch( anotherMessageType );
		Assert.equals( 1, module.callbackCount, "module callback should be triggered once again" );
		Assert.equals( 0, MockStateCommand.callCount, "'MockStateCommand' should not have been called this time" );
		Assert.equals( 1, MockExitStateCommand.callCount, "'MockExitStateCommand' should have been called" );
	}
}