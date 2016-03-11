package hex.ioc.core;

import hex.collection.HashMap;
import hex.collection.ILocatorListener;
import hex.control.macro.IMacroExecutor;
import hex.control.macro.MacroExecutor;
import hex.core.HashCodeFactory;
import hex.di.IBasicInjector;
import hex.di.IDependencyInjector;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.domain.DomainUtil;
import hex.domain.IApplicationDomainDispatcher;
import hex.error.IllegalArgumentException;
import hex.event.ClassAdapter;
import hex.event.EventProxy;
import hex.event.IAdapterStrategy;
import hex.event.IDispatcher;
import hex.event.IEvent;
import hex.event.MessageType;
import hex.inject.Injector;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.ApplicationAssemblerMessage;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.control.BuildArrayCommand;
import hex.ioc.control.BuildBooleanCommand;
import hex.ioc.control.BuildClassCommand;
import hex.ioc.control.BuildFloatCommand;
import hex.ioc.control.BuildFunctionCommand;
import hex.ioc.control.BuildInstanceCommand;
import hex.ioc.control.BuildIntCommand;
import hex.ioc.control.BuildMapCommand;
import hex.ioc.control.BuildNullCommand;
import hex.ioc.control.BuildObjectCommand;
import hex.ioc.control.BuildServiceLocatorCommand;
import hex.ioc.control.BuildStringCommand;
import hex.ioc.control.BuildUIntCommand;
import hex.ioc.control.BuildXMLCommand;
import hex.ioc.control.IBuildCommand;
import hex.ioc.locator.ConstructorVOLocator;
import hex.ioc.locator.DomainListenerVOLocator;
import hex.ioc.locator.MethodCallVOLocator;
import hex.ioc.locator.ModuleLocator;
import hex.ioc.locator.PropertyVOLocator;
import hex.ioc.locator.StateTransitionVOLocator;
import hex.ioc.vo.BuildHelperVO;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.ioc.vo.MapVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;
import hex.ioc.vo.StateTransitionVO;
import hex.log.Stringifier;
import hex.metadata.AnnotationProvider;
import hex.module.IModule;
import hex.service.IService;
import hex.service.ServiceConfiguration;
import hex.util.ObjectUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ContextFactory implements IContextFactory implements ILocatorListener<String, Dynamic>
{
	var _contextDispatcher			: IDispatcher<{}>;
	var _moduleLocator				: ModuleLocator;
	var _applicationContext 		: AbstractApplicationContext;
	var _commandMap 				: HashMap<String, Class<IBuildCommand>>;
	var _coreFactory 				: ICoreFactory;
	var _applicationDomainHub 		: IApplicationDomainDispatcher;
	var _IDExpert 					: IDExpert;
	var _constructorVOLocator 		: ConstructorVOLocator;
	var _propertyVOLocator 			: PropertyVOLocator;
	var _methodCallVOLocator 		: MethodCallVOLocator;
	var _domainListenerVOLocator 	: DomainListenerVOLocator;
	var _stateTransitionVOLocator 	: StateTransitionVOLocator;

	public function new( applicationContextName : String, applicationContextClass : Class<AbstractApplicationContext> = null  )
	{
		//build contextDispatcher
		var domain : Domain = DomainUtil.getDomain( applicationContextName, Domain );
		this._contextDispatcher = ApplicationDomainDispatcher.getInstance().getDomainDispatcher( domain );
		
		//build injector
		var injector = new Injector();
		injector.mapToValue( IBasicInjector, injector );
		injector.mapToValue( IDependencyInjector, injector );
		injector.mapToType( IMacroExecutor, MacroExecutor );
			
		//assign AnnotationProvider
		AnnotationProvider.getInstance( injector );
		
		//build coreFactory
		this._coreFactory = new CoreFactory( injector );
		
		if ( applicationContextClass != null )
		{
			this._applicationContext = Type.createInstance( applicationContextClass, [ this._contextDispatcher, this._coreFactory, applicationContextName ] );
		} 
		else
		{
			//ApplicationContext instantiation
			this._applicationContext = new ApplicationContext( this._contextDispatcher, this._coreFactory, applicationContextName );
		}
		
		//register applicationContext
		injector.mapToValue( ApplicationContext, this._applicationContext );
		this._coreFactory.register( applicationContextName, this._applicationContext );
		
		
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.CONTEXT_PARSED );
		this._init();
	}
	
	public function registerID( id : String ) : Bool
	{
		return this._IDExpert.register( id );
	}
	
	public function registerStateTransitionVO( id : String, stateTransitionVO : StateTransitionVO ) : Void
	{
		this._stateTransitionVOLocator.register( id, stateTransitionVO );
	}
	
	public function buildStateTransition( key : String ) : Void
	{
		this._stateTransitionVOLocator.buildStateTransition( key );
	}
	
	public function buildAllStateTransitions() : Void
	{
		var keys : Array<String> = this._stateTransitionVOLocator.keys();
		for ( key in keys )
		{
			this._stateTransitionVOLocator.buildStateTransition( key );
		}
		
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.STATE_TRANSITIONS_BUILT );
	}
	
	//
	public function registerPropertyVO( id : String, propertyVO : PropertyVO  ) : Void
	{
		if ( this._propertyVOLocator.isRegisteredWithKey( id ) )
		{
			( this._propertyVOLocator.locate( id ) ).push( propertyVO );
		}
		else
		{
			this._propertyVOLocator.register( id, [ propertyVO ] );
		}
	}
	
	function _getPropertyValue( property : PropertyVO ) : Dynamic
	{
		if ( property.method != null )
		{
			return this.build( new ConstructorVO( null, ContextTypeList.FUNCTION, [ property.method ] ) );

		} else if ( property.ref != null )
		{
			return this.build( new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, false, property.ref ) );

		} else if ( property.staticRef != null )
		{
			return this._coreFactory.getStaticReference( property.staticRef );

		} else
		{
			var type : String = property.type != null ? property.type : ContextTypeList.STRING;
			return this.build( new ConstructorVO( property.ownerID, type, [ property.value ] ) );
		}
	}

	function _setPropertyValue( property : PropertyVO, target : Dynamic ) : Void
	{
		var propertyName : String = property.name;
		if ( propertyName.indexOf(".") == -1 )
		{
			Reflect.setProperty( target, propertyName, this._getPropertyValue( property ) );
		}
		else
		{
			var props : Array<String> = propertyName.split( "." );
			propertyName = props.pop();
			var target : Dynamic = ObjectUtil.fastEvalFromTarget( target, props.join("."), this._coreFactory );
			Reflect.setProperty( target, propertyName, this._getPropertyValue( property ) );
		}
	}

	public function deserializeArguments( arguments : Array<Dynamic> ) : Array<Dynamic>
	{
		var result : Array<Dynamic> = null;
		var length : Int = arguments.length;

		if ( length > 0 ) 
		{
			result = [];
		}

		for ( obj in arguments )
		{
			if ( Std.is( obj, PropertyVO ) )
			{
				result.push( this._getPropertyValue( cast obj ) );
			}
			else if ( Std.is( obj, MapVO ) )
			{
				var mapVO : MapVO = cast obj;
				mapVO.key = this._getPropertyValue( mapVO.getPropertyKey() );
				mapVO.value = this._getPropertyValue( mapVO.getPropertyValue() );
				result.push( mapVO );
			}
		}

		return result;
	}
	
	//listen to CoreFactory
	public function onRegister( key : String, instance : Dynamic ) : Void
	{
		if ( this._propertyVOLocator.isRegisteredWithKey( key ) )
		{
			var properties : Array<PropertyVO> = this._propertyVOLocator.locate( key );
			for ( p in properties )
			{
				this._setPropertyValue( p, instance );
			}
		}
	}

    public function onUnregister( key : String ) : Void  { }
	public function handleEvent( e : IEvent ) : Void {}	
	
	//
	public function registerConstructorVO( id : String, constructorVO : ConstructorVO ) : Void
	{
		this._constructorVOLocator.register( id, constructorVO );
	}
	
	public function buildObject( id : String ) : Void
	{
		if ( this._constructorVOLocator.isRegisteredWithKey( id ) )
		{
			var cons : ConstructorVO = this._constructorVOLocator.locate( id );
			if ( cons.arguments != null )
			{
				cons.arguments = this.deserializeArguments( cons.arguments );
			}

			this.build( cons, id );
			this._constructorVOLocator.unregister( id );
		}
	}
	
	public function buildAllObjects() : Void
	{
		var keys : Array<String> = this._constructorVOLocator.keys();
		for ( key in keys )
		{
			this.buildObject( key );
		}
		
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.OBJECTS_BUILT );
	}
	
	public function registerDomainListenerVO( domainListenerVO : DomainListenerVO ) : Void
	{
		this._domainListenerVOLocator.register( "" + HashCodeFactory.getKey( domainListenerVO ), domainListenerVO );
	}
		
	public function assignAllDomainListeners() : Void
	{
		var listeners : Array<String> = this._domainListenerVOLocator.keys();
		for ( key in listeners )
		{
			this.assignDomainListener( key );
		}
		
		this._domainListenerVOLocator.clear();
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.DOMAIN_LISTENERS_ASSIGNED );
	}

	public function assignDomainListener( id : String ) : Bool
	{
		var domainListener : DomainListenerVO			= this._domainListenerVOLocator.locate( id );
		var listener : Dynamic 							= this._coreFactory.locate( domainListener.ownerID );
		var args : Array<DomainListenerVOArguments> 	= domainListener.arguments;

		// Check if event provider is a service
		var service : IService<ServiceConfiguration> = null;
		if ( this._coreFactory.isRegisteredWithKey( domainListener.listenedDomainName ) )
		{
			var located : Dynamic = this._coreFactory.locate( domainListener.listenedDomainName );
			if ( Std.is( located, IService ) )
			{
				service = cast located;
			}
		}

		if ( args != null && args.length > 0 )
		{
			for ( domainListenerArgument in args )
			{
				var method : String = Std.is( listener, EventProxy ) ? "handleCallback" : domainListenerArgument.method;
				
				var messageType : MessageType = domainListenerArgument.name != null ? 
												new MessageType( domainListenerArgument.name ) : 
												this._coreFactory.getStaticReference( domainListenerArgument.staticRef );

				if ( ( method != null && Reflect.isFunction( Reflect.field( listener, method ) )) || domainListenerArgument.strategy != null )
				{
					var callback : Dynamic = domainListenerArgument.strategy != null ? this._getStrategyCallback( listener, method, domainListenerArgument.strategy, domainListenerArgument.injectedInModule ) : Reflect.field( listener, method );

					if ( service == null )
					{
						var domain : Domain = DomainUtil.getDomain( domainListener.listenedDomainName, Domain );
						this._applicationDomainHub.addHandler( messageType, listener, callback, domain );
					}
					else
					{
						service.addHandler( messageType, listener, callback );
					}
				}
				else
				{
					if ( method == null )
					{
						throw new IllegalArgumentException( this + ".assignDomainListener failed. Callback should be defined (use 'method' attribute) in instance of '" 
															+ Stringifier.stringify( listener ) + "' class with '" + domainListener.ownerID + "' id" );
					}
					else
					{
						throw new IllegalArgumentException( this + ".assignDomainListener failed. Method named '" + method + "' can't be found in instance of '" 
															+ Stringifier.stringify( listener ) + "' class with '" + domainListener.ownerID + "' id" );
					}
				}
			}

			return true;

		} else
		{
			var domain : Domain = DomainUtil.getDomain( domainListener.listenedDomainName, Domain );
			return this._applicationDomainHub.addListener( listener, domain );
		}
	}

	function _getStrategyCallback( listener : Dynamic, method : String, strategyClassName : String, injectedInModule : Bool = false ) : Dynamic
	{
		var callback : Dynamic 							= Reflect.field( listener, method );
		var strategyClass : Class<IAdapterStrategy> 	= cast this._coreFactory.getClassReference( strategyClassName );
		
		
		var adapter = new ClassAdapter();
		adapter.setCallBackMethod( listener, callback );
		adapter.setAdapterClass( strategyClass );
		
		if ( injectedInModule && Std.is( listener, IModule ) )
		{
			var basicInjector : IBasicInjector = listener.getBasicInjector();
			adapter.setFactoryMethod( basicInjector, basicInjector.instantiateUnmapped );
		}
		else 
		{
			adapter.setFactoryMethod( this._applicationContext.getBasicInjector(), this._applicationContext.getBasicInjector().instantiateUnmapped );
		}
		
		var f:Array<Dynamic>->Void = function( rest:Array<Dynamic> ):Void
		{
			( adapter.getCallbackAdapter() )( rest );
		}
		
		return Reflect.makeVarArgs( f );
	}
	
	public function registerMethodCallVO( methodCallVO : MethodCallVO ) : Void
	{
		var index : Int = this._methodCallVOLocator.keys().length +1;
		this._methodCallVOLocator.register( "" + index, methodCallVO );
	}
	
	public function callMethod( id : String ) : Void
	{
		var method : MethodCallVO 	= this._methodCallVOLocator.locate( id );
		var cons = new ConstructorVO( null, ContextTypeList.FUNCTION, [ method.ownerID + "." + method.name ] );
		var func : Dynamic 			= this.build( cons );
		var args : Array<Dynamic> 	= this.deserializeArguments( method.arguments );
		
		Reflect.callMethod( this._coreFactory.locate( method.ownerID ), func, args );
	}

	public function callAllMethods() : Void
	{
		var keyList : Array<String> = this._methodCallVOLocator.keys();
		for ( key in keyList )
		{
			this.callMethod(  key );
		}
		
		this._methodCallVOLocator.clear();
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.METHODS_CALLED );
	}
	
	public function callModuleInitialisation() : Void
	{
		this._moduleLocator.callModuleInitialisation();
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.MODULES_INITIALIZED );
	}

	public function getApplicationContext() : AbstractApplicationContext
	{
		return this._applicationContext;
	}

	public function getCoreFactory() : ICoreFactory
	{
		return this._coreFactory;
	}

	public function getDomainListenerVOLocator() : DomainListenerVOLocator
	{
		return this._domainListenerVOLocator;
	}
	
	public function getStateTransitionVOLocator() : StateTransitionVOLocator
	{
		return this._stateTransitionVOLocator;
	}

	function _init() : Void
	{
		this._commandMap 				= new HashMap<String, Class<IBuildCommand>>();
		this._applicationDomainHub 		= ApplicationDomainDispatcher.getInstance();
		this._IDExpert 					= new IDExpert();
		this._constructorVOLocator 		= new ConstructorVOLocator();
		this._propertyVOLocator 		= new PropertyVOLocator();
		this._methodCallVOLocator 		= new MethodCallVOLocator();
		this._domainListenerVOLocator 	= new DomainListenerVOLocator();
		this._stateTransitionVOLocator 	= new StateTransitionVOLocator( this );
		this._moduleLocator 			= new ModuleLocator( this );

		this.addType( ContextTypeList.ARRAY, BuildArrayCommand );
		this.addType( ContextTypeList.BOOLEAN, BuildBooleanCommand );
		this.addType( ContextTypeList.INSTANCE, BuildInstanceCommand );
		this.addType( ContextTypeList.INT, BuildIntCommand );
		this.addType( ContextTypeList.NULL, BuildNullCommand );
		this.addType( ContextTypeList.FLOAT, BuildFloatCommand );
		this.addType( ContextTypeList.OBJECT, BuildObjectCommand );
		this.addType( ContextTypeList.STRING, BuildStringCommand );
		this.addType( ContextTypeList.UINT, BuildUIntCommand );
		this.addType( ContextTypeList.DEFAULT, BuildStringCommand );
		this.addType( ContextTypeList.HASHMAP, BuildMapCommand );
		this.addType( ContextTypeList.SERVICE_LOCATOR, BuildServiceLocatorCommand );
		this.addType( ContextTypeList.CLASS, BuildClassCommand );
		this.addType( ContextTypeList.XML, BuildXMLCommand );
		this.addType( ContextTypeList.FUNCTION, BuildFunctionCommand );
		this.addType( ContextTypeList.UNKNOWN, BuildInstanceCommand );
		
		this._coreFactory.addListener( this );
	}

	public function addType( type : String, build : Class<IBuildCommand> ) : Void
	{
		this._commandMap.put( type, build );
	}

	public function build( constructorVO : ConstructorVO, ?id : String ) : Dynamic
	{
		var type : String = constructorVO.type;
		var commandClass : Class<IBuildCommand> = ( this._commandMap.containsKey( type ) ) ? this._commandMap.get( type ) : this._commandMap.get( ContextTypeList.INSTANCE );
		var buildCommand : IBuildCommand = Type.createInstance( commandClass, [] );

		var builderHelperVO = new BuildHelperVO();
		builderHelperVO.type 					= type;
		builderHelperVO.builderFactory 			= this;
		builderHelperVO.coreFactory 			= this._coreFactory;
		builderHelperVO.constructorVO 			= constructorVO;
		builderHelperVO.moduleLocator 			= this._moduleLocator;

		buildCommand.setHelper( builderHelperVO );
		Reflect.callMethod( buildCommand, buildCommand.getExecuteMethod(), [] );

		if ( id != null )
		{
			this._coreFactory.register( id, constructorVO.result );
		}

		return constructorVO.result;
	}

	public function release() : Void
	{
		this._coreFactory.removeListener( this );
		this._coreFactory.clear();
		this._constructorVOLocator.release();
		this._propertyVOLocator.release();
		this._methodCallVOLocator.release();
		this._domainListenerVOLocator.release();
		this._stateTransitionVOLocator.release();
		this._moduleLocator.release();
		this._commandMap.clear();
		this._IDExpert.clear();
	}
}