package hex.ioc.core;

import hex.collection.ILocatorListener;
import hex.control.macro.IMacroExecutor;
import hex.control.macro.MacroExecutor;
import hex.core.HashCodeFactory;
import hex.di.IBasicInjector;
import hex.di.IDependencyInjector;
import hex.di.Injector;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.domain.DomainUtil;
import hex.domain.IApplicationDomainDispatcher;
import hex.event.IDispatcher;
import hex.event.IEvent;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.ApplicationAssemblerMessage;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.control.ArrayFactory;
import hex.ioc.control.BoolFactory;
import hex.ioc.control.ClassFactory;
import hex.ioc.control.ClassInstanceFactory;
import hex.ioc.control.DomainListenerFactory;
import hex.ioc.control.DynamicObjectFactory;
import hex.ioc.control.FloatFactory;
import hex.ioc.control.FunctionFactory;
import hex.ioc.control.HashMapFactory;
import hex.ioc.control.IntFactory;
import hex.ioc.control.NullFactory;
import hex.ioc.control.ServiceLocatorFactory;
import hex.ioc.control.StringFactory;
import hex.ioc.control.UIntFactory;
import hex.ioc.control.XmlFactory;
import hex.ioc.locator.ConstructorVOLocator;
import hex.ioc.locator.DomainListenerVOLocator;
import hex.ioc.locator.MethodCallVOLocator;
import hex.ioc.locator.ModuleLocator;
import hex.ioc.locator.PropertyVOLocator;
import hex.ioc.locator.StateTransitionVOLocator;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.MapVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;
import hex.ioc.vo.StateTransitionVO;
import hex.metadata.AnnotationProvider;
import hex.metadata.IAnnotationProvider;

/**
 * ...
 * @author Francis Bourre
 */
class ContextFactory implements IContextFactory implements ILocatorListener<String, Dynamic>
{
	var _annotationProvider			: IAnnotationProvider;
	var _contextDispatcher			: IDispatcher<{}>;
	var _moduleLocator				: ModuleLocator;
	var _applicationContext 		: AbstractApplicationContext;
	var _factoryMap 				: Map<String, FactoryVO->Void>;
	var _coreFactory 				: ICoreFactory;
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
		
		//build annotation provider
		this._annotationProvider = new AnnotationProvider();
		this._annotationProvider.registerInjector( injector );
		
		//build coreFactory
		this._coreFactory = new CoreFactory( injector, this._annotationProvider );
		
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
			this._propertyVOLocator.locate( id ).push( propertyVO );
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
			return this._build( new ConstructorVO( null, ContextTypeList.FUNCTION, [ property.method ] ) );

		} else if ( property.ref != null )
		{
			return this._build( new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, false, property.ref ) );

		} else if ( property.staticRef != null )
		{
			return this._coreFactory.getStaticReference( property.staticRef );

		} else
		{
			var type : String = property.type != null ? property.type : ContextTypeList.STRING;
			return this._build( new ConstructorVO( property.ownerID, type, [ property.value ] ) );
		}
	}

	function _setPropertyValue( property : PropertyVO, target : Dynamic, id : String ) : Void
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
			var target : Dynamic = this._coreFactory.fastEvalFromTarget( target, props.join(".") );
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
				this._setPropertyValue( p, instance, key );
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

			this._build( cons, id );
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
		var func : Dynamic 			= this._build( cons );
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
	
	public function getAnnotationProvider() : IAnnotationProvider
	{
		return this._annotationProvider;
	}
	
	public function getStateTransitionVOLocator() : StateTransitionVOLocator
	{
		return this._stateTransitionVOLocator;
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
		this._factoryMap = new Map();
		this._IDExpert.clear();
	}

	function _init() : Void
	{
		this._factoryMap 				= new Map();
		this._IDExpert 					= new IDExpert();
		this._constructorVOLocator 		= new ConstructorVOLocator();
		this._propertyVOLocator 		= new PropertyVOLocator();
		this._methodCallVOLocator 		= new MethodCallVOLocator();
		this._domainListenerVOLocator 	= new DomainListenerVOLocator();
		this._stateTransitionVOLocator 	= new StateTransitionVOLocator( this );
		this._moduleLocator 			= new ModuleLocator( this );

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
		this._factoryMap.set( ContextTypeList.SERVICE_LOCATOR, ServiceLocatorFactory.build );
		this._factoryMap.set( ContextTypeList.CLASS, ClassFactory.build );
		this._factoryMap.set( ContextTypeList.XML, XmlFactory.build );
		this._factoryMap.set( ContextTypeList.FUNCTION, FunctionFactory.build );
		this._factoryMap.set( ContextTypeList.INSTANCE, ClassInstanceFactory.build );
		
		this._coreFactory.addListener( this );
	}

	function _build( constructorVO : ConstructorVO, ?id : String ) : Dynamic
	{
		var type 								= constructorVO.type;
		var buildMethod 						= ( this._factoryMap.exists( type ) ) ? this._factoryMap.get( type ) : ClassInstanceFactory.build;

		var builderHelperVO 					= new FactoryVO();
		builderHelperVO.type 					= type;
		builderHelperVO.contextFactory 			= this;
		builderHelperVO.coreFactory 			= this._coreFactory;
		builderHelperVO.constructorVO 			= constructorVO;
		builderHelperVO.moduleLocator 			= this._moduleLocator;

		buildMethod( builderHelperVO );

		if ( id != null )
		{
			this._coreFactory.register( id, constructorVO.result );
		}

		return constructorVO.result;
	}
}