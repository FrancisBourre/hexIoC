package hex.ioc.assembler;

import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.domain.DomainUtil;
import hex.event.IDispatcher;
import hex.event.MessageType;
import hex.ioc.core.ICoreFactory;
import hex.state.State;
import hex.state.StateMachine;
import hex.state.control.StateController;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContext extends AbstractApplicationContext
{
	var _dispatcher 			: IDispatcher<{}>;
	var _stateMachine 			: StateMachine;
	var _stateController 		: StateController;
	
	public var state(default, null) : ApplicationContextStateList;
		
	@:allow( hex.ioc.core )
	function new( dispatcher : IDispatcher<{}>, coreFactory : ICoreFactory, name : String )
	{
		super( coreFactory, name );
		this._dispatcher = dispatcher;
		this._initStateMachine();
	}
	
	function _initStateList() : Void
	{
		this.state = new ApplicationContextStateList();
	}
	
	function _initStateMachine() : Void
	{
		this._initStateList();
		this._stateMachine = new StateMachine( this.state.CONTEXT_INITIALIZED );
		this._stateController = new StateController( this.getBasicInjector(), this._stateMachine );
		this._dispatcher.addListener( this._stateController );
	}
	
	@:allow( hex.ioc.assembler )
	override function _dispatch( messageType : MessageType, ?data : Array<Dynamic> ) : Void
	{
		this._dispatcher.dispatch( messageType, data );
	}
	
	public function getCurrentState() : State
	{
		return this._stateController.getCurrentState();
	}
}