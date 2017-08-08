package hex.ioc.core;

import hex.collection.ILocatorListener;
import hex.collection.ILocator;
import hex.collection.Locator;
import hex.core.ApplicationAssemblerMessage;
import hex.core.ContextTypeList;
import hex.core.HashCodeFactory;
import hex.core.IApplicationContext;
import hex.core.IBuilder;
import hex.core.SymbolTable;
import hex.domain.ApplicationDomainDispatcher;
import hex.event.IDispatcher;
import hex.factory.BuildRequest;
import hex.runtime.factory.ArrayFactory;
import hex.runtime.factory.BoolFactory;
import hex.runtime.factory.ClassFactory;
import hex.ioc.control.ClassInstanceFactory;
import hex.ioc.control.DomainListenerFactory;
import hex.runtime.factory.DynamicObjectFactory;
import hex.runtime.factory.FloatFactory;
import hex.runtime.factory.FunctionFactory;
import hex.runtime.factory.HashMapFactory;
import hex.runtime.factory.IntFactory;
import hex.runtime.factory.MappingConfigurationFactory;
import hex.runtime.factory.NullFactory;
import hex.runtime.factory.PropertyFactory;
import hex.ioc.control.StateTransitionFactory;
import hex.runtime.factory.StaticVariableFactory;
import hex.runtime.factory.StringFactory;
import hex.runtime.factory.UIntFactory;
import hex.runtime.factory.XmlFactory;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.StateTransitionVO;
import hex.ioc.vo.TransitionVO;
import hex.metadata.IAnnotationProvider;
import hex.module.IModule;
import hex.runtime.basic.IRunTimeContextFactory;
import hex.runtime.basic.IRunTimeCoreFactory;
import hex.runtime.basic.vo.FactoryVOTypeDef;
import hex.vo.ConstructorVO;
import hex.vo.MethodCallVO;
import hex.vo.PropertyVO;

/**
 * ...
 * @author Francis Bourre
 */
@:keepSub
class ContextFactory 
	implements IBuilder<BuildRequest>
	implements IRunTimeContextFactory 
	implements ILocatorListener<String, Dynamic>
{
	var _isInitialized				: Bool;
	
	var _annotationProvider			: IAnnotationProvider;
	var _contextDispatcher			: IDispatcher<{}>;
	var _moduleLocator				: Locator<String, IModule>;
	var _applicationContext 		: IApplicationContext;
	var _factoryMap 				: Map<String, FactoryVOTypeDef->Dynamic>;
	var _coreFactory 				: IRunTimeCoreFactory;
	var _symbolTable 				: SymbolTable;
	var _constructorVOLocator 		: Locator<String, ConstructorVO>;
	var _propertyVOLocator 			: Locator<String, Array<PropertyVO>>;
	var _methodCallVOLocator 		: Locator<String, MethodCallVO>;
	var _typeLocator 				: Locator<String, String>;
	var _domainListenerVOLocator 	: Locator<String, DomainListenerVO>;
	var _stateTransitionVOLocator 	: Locator<String, StateTransitionVO>;
	
	var _transitions				: Array<TransitionVO>;
	var _injectedInto				: Array<Any>;

	public function new()
	{
		this._isInitialized = false;
	}
	
	public function init( applicationContext : IApplicationContext ) : Void
	{
		if ( !this._isInitialized )
		{
			this._isInitialized = true;
			
			//settings
			this._applicationContext = applicationContext;
			this._contextDispatcher = ApplicationDomainDispatcher.getInstance( this._applicationContext ).getDomainDispatcher( applicationContext.getDomain() );
			var injector = this._applicationContext.getInjector();
			this._annotationProvider = injector.getInstance( IAnnotationProvider );
			this._coreFactory = cast ( applicationContext.getCoreFactory(), IRunTimeCoreFactory );

			//initialization
			this._contextDispatcher.dispatch( ApplicationAssemblerMessage.CONTEXT_PARSED );
			
			//
			this._factoryMap 				= new Map();
			this._symbolTable 				= new SymbolTable();
			this._constructorVOLocator 		= new Locator();
			this._propertyVOLocator 		= new Locator();
			this._methodCallVOLocator 		= new Locator();
			this._typeLocator 				= new Locator();
			this._domainListenerVOLocator 	= new Locator();
			this._stateTransitionVOLocator 	= new Locator();
			this._moduleLocator 			= new Locator();
			this._injectedInto				= [];

			this._factoryMap.set( ContextTypeList.ARRAY, ArrayFactory.build );
			this._factoryMap.set( ContextTypeList.BOOLEAN, BoolFactory.build );
			this._factoryMap.set( ContextTypeList.INT, IntFactory.build );
			this._factoryMap.set( ContextTypeList.NULL, NullFactory.build );
			this._factoryMap.set( ContextTypeList.FLOAT, FloatFactory.build );
			this._factoryMap.set( ContextTypeList.OBJECT, DynamicObjectFactory.build );
			this._factoryMap.set( ContextTypeList.STRING, StringFactory.build );
			this._factoryMap.set( ContextTypeList.UINT, UIntFactory.build );
			this._factoryMap.set( ContextTypeList.DEFAULT, StringFactory.build );
			this._factoryMap.set( ContextTypeList.HASHMAP, HashMapFactory.build );
			this._factoryMap.set( ContextTypeList.CLASS, ClassFactory.build );
			this._factoryMap.set( ContextTypeList.XML, XmlFactory.build );
			this._factoryMap.set( ContextTypeList.FUNCTION, FunctionFactory.build );
			this._factoryMap.set( ContextTypeList.INSTANCE, ClassInstanceFactory.build );
			this._factoryMap.set( ContextTypeList.STATIC_VARIABLE, StaticVariableFactory.build );
			this._factoryMap.set( ContextTypeList.MAPPING_CONFIG, MappingConfigurationFactory.build );
			
			this._coreFactory.addListener( this );
		}
	}
	
	public function build( request : BuildRequest ) : Void
	{
		switch( request )
		{
			case PREPROCESS( vo ): this.preprocess( vo );
			case OBJECT( vo ): this.registerConstructorVO( vo );
			case PROPERTY( vo ): this.registerPropertyVO( vo );
			case METHOD_CALL( vo ): this.registerMethodCallVO( vo );
			case DOMAIN_LISTENER( vo ): this.registerDomainListenerVO( vo );
			case STATE_TRANSITION( vo ): this.registerStateTransitionVO( vo );
		}
	}
	
	public function finalize() : Void
	{
		this.buildAllStateTransitions();
		this.dispatchAssemblingStart();
		this.buildAllObjects();
		this.assignAllDomainListeners();
		this.callAllMethods();
		this.callModuleInitialisation();
		this.dispatchAssemblingEnd();
		this.dispatchIdleMode();
	}
	
	public function dispose() : Void
	{
		this._coreFactory.removeListener( this );
		this._coreFactory.clear();
		this._constructorVOLocator.release();
		this._propertyVOLocator.release();
		this._methodCallVOLocator.release();
		this._typeLocator.release();
		this._domainListenerVOLocator.release();
		this._stateTransitionVOLocator.release();
		this._moduleLocator.release();
		this._factoryMap = new Map();
		this._symbolTable.clear();
		this._injectedInto = [];
	}
	
	public function getCoreFactory() : IRunTimeCoreFactory
	{
		return this._coreFactory;
	}
	
	public function getTypeLocator() : ILocator<String, String>
	{
		return this._typeLocator;
	}
	
	public function dispatchAssemblingStart() : Void
	{
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.ASSEMBLING_START );
	}
	
	public function dispatchAssemblingEnd() : Void
	{
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.ASSEMBLING_END );
	}
	
	public function dispatchIdleMode() : Void
	{
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.IDLE_MODE );
	}
	
	public function registerStateTransitionVO( stateTransitionVO : StateTransitionVO ) : Void
	{
		this._stateTransitionVOLocator.register( stateTransitionVO.ID, stateTransitionVO );
	}
	
	public function buildStateTransition( key : String ) : Array<TransitionVO>
	{
		var transitions : Array<TransitionVO> = null;
		
		if ( this._stateTransitionVOLocator.isRegisteredWithKey( key ) )
		{
			transitions = StateTransitionFactory.build( this._stateTransitionVOLocator.locate( key ), this );
			this._stateTransitionVOLocator.unregister( key );
		}
		
		return transitions;
	}
	
	public function buildAllStateTransitions() : Void
	{
		this._transitions = [];
		var keys : Array<String> = this._stateTransitionVOLocator.keys();
		
		for ( key in keys )
		{
			this._transitions = this._transitions.concat( this.buildStateTransition( key ) );
		}
		
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.STATE_TRANSITIONS_BUILT );
	}
	
	//
	public function preprocess( vo : hex.vo.PreProcessVO ) : Void
	{
		//We don't have any preprocessor for now
	}
	
	public function registerPropertyVO( propertyVO : PropertyVO  ) : Void
	{
		var id = propertyVO.ownerID;
		
		if ( this._propertyVOLocator.isRegisteredWithKey( id ) )
		{
			this._propertyVOLocator.locate( id ).push( propertyVO );
		}
		else
		{
			this._propertyVOLocator.register( id, [ propertyVO ] );
		}
	}
	
	//listen to CoreFactory
	public function onRegister( key : String, instance : Dynamic ) : Void
	{
		if ( this._propertyVOLocator.isRegisteredWithKey( key ) )
		{
			var properties = this._propertyVOLocator.locate( key );
			for ( p in properties ) 
				PropertyFactory.build( this, p, instance );
		}
	}

    public function onUnregister( key : String ) : Void  { }
	
	//
	public function registerConstructorVO( constructorVO : ConstructorVO ) : Void
	{
		this._constructorVOLocator.register( constructorVO.ID, constructorVO );
	}
	
	public function buildObject( id : String ) : Void
	{
		if ( this._constructorVOLocator.isRegisteredWithKey( id ) )
		{
			this.buildVO( this._constructorVOLocator.locate( id ), id );
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
		
		if ( this._injectedInto.length > 0 )
		{
			var injector = this._applicationContext.getInjector();
			for ( element in this._injectedInto )
			{
				injector.injectInto( element );
			}
		}
		
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.OBJECTS_BUILT );
		
		StateTransitionFactory.flush( this._coreFactory, this._transitions );
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
		return DomainListenerFactory.build( id, this._domainListenerVOLocator, this._applicationContext, this._annotationProvider );
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
		var func : Dynamic 			= this.buildVO( cons );
		
		var arguments = method.arguments;
		var l : Int = arguments.length;
		for ( i in 0...l )
		{
			arguments[ i ] = this.buildVO( arguments[ i ] );
		}
		
		Reflect.callMethod( this._coreFactory.locate( method.ownerID ), func, arguments );
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
		var modules = this._moduleLocator.values();
		for ( module in modules )
		{
			module.initialize( this._applicationContext );
		}
		this._moduleLocator.clear();
		
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.MODULES_INITIALIZED );
	}

	public function getApplicationContext() : IApplicationContext
	{
		return this._applicationContext;
	}
	
	public function getAnnotationProvider() : IAnnotationProvider
	{
		return this._annotationProvider;
	}
	
	public function getStateTransitionVOLocator() : Locator<String, StateTransitionVO>
	{
		return this._stateTransitionVOLocator;
	}

	public function buildVO( constructorVO : ConstructorVO, ?id : String ) : Dynamic
	{
		var buildMethod : FactoryVOTypeDef->Dynamic = null;
		
		//TODO better type checking
		var type 						= constructorVO.className.split( "<" )[ 0 ];
		var buildMethod 				= ( this._factoryMap.exists( type ) ) ? this._factoryMap.get( type ) : ClassInstanceFactory.build;

		//build instance with the expected factory method
		var result 	= buildMethod( this._getFactoryVO( constructorVO ) );

		//Mapped types
		if ( constructorVO.mapTypes != null )
		{
			var mapTypes = constructorVO.mapTypes;
			for ( mapType in mapTypes )
			{
				//Remove whitespaces
				mapType = mapType.split( ' ' ).join( '' );
				
				this.getApplicationContext().getInjector()
					.mapClassNameToValue( mapType, result, constructorVO.ID );
			}
		}

		//Inject into
		if ( constructorVO.injectInto )
		{
			this._injectedInto.push( result );
		}
		
		if ( id != null )
		{
			this._typeLocator.register( id, constructorVO.type );
			
			//keep track of Module instances for initializing them
			// bugfix : should cast result to prevent that var result is typed as IModule on Flash target
			if ( Std.is( result, IModule ) )
				this._moduleLocator.register( id, cast(result, IModule) );

			this._coreFactory.register( id, result );
		}

		return result;
	}
	
	function _getFactoryVO( constructorVO : ConstructorVO = null ) : FactoryVOTypeDef
	{
		return { constructorVO : constructorVO, contextFactory : this };
	}
}