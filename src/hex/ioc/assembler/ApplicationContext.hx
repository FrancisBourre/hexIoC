package hex.ioc.assembler;

import hex.control.macro.IMacroExecutor;
import hex.control.macro.MacroExecutor;
import hex.core.IApplicationContext;
import hex.di.IBasicInjector;
import hex.di.IDependencyInjector;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.domain.DomainUtil;
import hex.event.IDispatcher;
import hex.event.MessageType;
import hex.ioc.core.CoreFactory;
import hex.log.DomainLogger;
import hex.log.ILogger;
import hex.metadata.AnnotationProvider;
import hex.metadata.IAnnotationProvider;
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
		var domain = DomainUtil.getDomain( applicationContextName, Domain );
		var contextDispatcher = ApplicationDomainDispatcher.getInstance().getDomainDispatcher( domain );
		
		//build injector
		var injector : IDependencyInjector = cast Type.createInstance( Type.resolveClass( 'hex.di.Injector' ), [] );
		injector.mapToValue( IBasicInjector, injector );
		injector.mapToValue( IDependencyInjector, injector );
		injector.mapToType( IMacroExecutor, MacroExecutor );
		
		var logger = new DomainLogger( domain );
		injector.mapToValue( ILogger, logger );
		
		//build annotation provider
		var annotationProvider = AnnotationProvider.getAnnotationProvider( DomainUtil.getDomain( applicationContextName, Domain ) );
		annotationProvider.registerInjector( injector );
		injector.mapToValue( IAnnotationProvider, annotationProvider );
		
		//build coreFactory
		var coreFactory = new CoreFactory( injector, annotationProvider );
		
		//register applicationContext
		injector.mapToValue( IApplicationContext, this );
		coreFactory.register( applicationContextName, this );
		
		super( coreFactory, applicationContextName );
		
		coreFactory.getInjector().mapClassNameToValue( "hex.event.IDispatcher<{}>", contextDispatcher );
		this._dispatcher = contextDispatcher;
		this._initStateMachine();
	}
	
	override public function dispose() : Void
	{
		var injector = this.getInjector();
		var annotationProvider = AnnotationProvider.getAnnotationProvider( DomainUtil.getDomain( this.getName(), Domain ) );
		annotationProvider.unregisterInjector( injector );
		
		//TODO replace by annotationProvider.dispose();
		AnnotationProvider.release();
		
		super.dispose();
	}
}