package hex.ioc.assembler;

import hex.control.macro.IMacroExecutor;
import hex.control.macro.MacroExecutor;
import hex.core.AbstractApplicationContext;
import hex.core.IApplicationContext;
import hex.di.IBasicInjector;
import hex.di.IDependencyInjector;
import hex.di.Injector;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.error.IllegalStateException;
import hex.event.IDispatcher;
import hex.event.MessageType;
import hex.ioc.core.CoreFactory;
import hex.log.ILogger;
import hex.log.LogManager;
import hex.metadata.AnnotationProvider;
import hex.metadata.IAnnotationProvider;
import hex.module.IContextModule;
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
	
	function _initStateList() : Void
	{
		this.state = new ApplicationContextStateList();
	}
	
	function _initStateMachine() : Void
	{
		this._initStateList();
		this._stateMachine = new StateMachine( this.state.CONTEXT_INITIALIZED );
		this._stateController = new StateController( this.getInjector(), this._stateMachine );
		this._dispatcher.addListener( this._stateController );
	}
	
	override public function dispatch( messageType : MessageType, ?data : Array<Dynamic> ) : Void
	{
		this._dispatcher.dispatch( messageType, data );
	}
	
	public function getCurrentState() : State
	{
		return this._stateController.getCurrentState();
	}
	
	@:allow( hex.runtime )
	function new( applicationContextName : String )
	{
		//build contextDispatcher
		var domain = Domain.getDomain( applicationContextName );
		var contextDispatcher = ApplicationDomainDispatcher.getInstance( this ).getDomainDispatcher( domain );
		
		//build injector
		var injector : IDependencyInjector = cast Type.createInstance( Injector, [] );
		injector.mapToValue( IBasicInjector, injector );
		injector.mapToValue( IDependencyInjector, injector );
		injector.mapToType( IMacroExecutor, MacroExecutor );
		
		var logger = LogManager.getLogger( domain.getName() );
		injector.mapToValue( ILogger, logger );
		
		//build annotation provider
		var annotationProvider = AnnotationProvider.getAnnotationProvider( Domain.getDomain( applicationContextName ) );
		annotationProvider.registerInjector( injector );
		injector.mapToValue( IAnnotationProvider, annotationProvider );
		
		//build coreFactory
		var coreFactory = new CoreFactory( injector, annotationProvider );
		
		//register applicationContext
		injector.mapToValue( IApplicationContext, this );
		injector.mapToValue( IContextModule, this );
		coreFactory.register( applicationContextName, this );
		
		super( coreFactory, applicationContextName );
		
		coreFactory.getInjector().mapClassNameToValue( "hex.event.IDispatcher<{}>", contextDispatcher );
		this._dispatcher = contextDispatcher;
		this._initStateMachine();
		
		this.initialize( null );
	}
	
	/**
	 * Override and implement
	 */
	override function _onInitialisation() : Void
	{

	}

	/**
	 * Override and implement
	 */
	override function _onRelease() : Void
	{
		var injector = this.getInjector();
		var annotationProvider = AnnotationProvider.getAnnotationProvider( Domain.getDomain( this.getName() ) );
		annotationProvider.unregisterInjector( injector );
		
		//TODO replace by annotationProvider.dispose();
		AnnotationProvider.release();
	}
}