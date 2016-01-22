package hex.ioc.assembler;

import hex.control.macro.IMacroExecutor;
import hex.control.macro.MacroExecutor;
import hex.di.IBasicInjector;
import hex.di.IContextOwner;
import hex.di.IDependencyInjector;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.domain.DomainUtil;
import hex.error.IllegalArgumentException;
import hex.event.IDispatcher;
import hex.event.MessageType;
import hex.inject.Injector;
import hex.ioc.assembler.IApplicationAssembler;
import hex.log.Logger;
import hex.metadata.AnnotationProvider;
import hex.metadata.IAnnotationProvider;
import hex.state.control.StateController;
import hex.state.State;
import hex.state.StateMachine;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContext implements IContextOwner implements Dynamic<ApplicationContext>
{
	private var _name 					: String;
	private var _applicationAssembler 	: IApplicationAssembler;
	private var _dispatcher 			: IDispatcher<{}>;
	private var _injector 				: Injector;
	private var _annotationProvider 	: IAnnotationProvider;
	
	private var _stateMachine 			: StateMachine;
	private var _stateController 		: StateController;
		
	@:allow( hex.ioc.assembler )
	private function new( applicationAssembler : IApplicationAssembler, name : String )
	{
		var domain : Domain = DomainUtil.getDomain( name, Domain );
		this._dispatcher = ApplicationDomainDispatcher.getInstance().getDomainDispatcher( domain );
		
		this._injector = new Injector();
		this._injector.mapToValue( IBasicInjector, this._injector );
		this._injector.mapToValue( IDependencyInjector, this._injector );
		this._injector.mapToType( IMacroExecutor, MacroExecutor );
		
		this._injector.mapToValue( ApplicationContext, this );
		
		this._annotationProvider 		= AnnotationProvider.getInstance( this._injector );
		this._name 					= name;
		this._applicationAssembler 	= applicationAssembler;
		
		this._stateMachine = new StateMachine( ApplicationAssemblerState.CONTEXT_INITIALIZED );
		this._stateController = new StateController( this._injector, this._stateMachine );
		this._dispatcher.addListener( this._stateController );
	}
	
	@:allow( hex.ioc.assembler )
	private function _dispatch( messageType : MessageType, ?data : Array<Dynamic> ) : Void
	{
		this._dispatcher.dispatch( messageType, data );
	}

	public function getName() : String
	{
		return this._name;
	}
	
	public function getCurrentState() : State
	{
		return this._stateController.getCurrentState();
	}
	
	function resolve( field : String )
	{
		return this._applicationAssembler.getBuilderFactory( this ).getCoreFactory().locate( field );
	}

	public function addChild( applicationContext : ApplicationContext ) : Bool
	{
		try
		{
			return this._applicationAssembler.getBuilderFactory( this ).getCoreFactory().register( applicationContext.getName(), applicationContext );
		}
		catch ( ex : IllegalArgumentException )
		{
			#if debug
			Logger.ERROR( "addChild failed with applicationContext named '" + applicationContext.getName() + "'" );
			#end
			return false;
		}
	}

	public function getBasicInjector() : IBasicInjector 
	{
		return this._injector;
	}
}