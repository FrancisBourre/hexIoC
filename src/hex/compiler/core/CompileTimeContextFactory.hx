package hex.compiler.core;

import haxe.macro.Expr;
import hex.collection.ILocatorListener;
import hex.compiler.core.CompileTimeCoreFactory;
import hex.compiler.factory.ArrayFactory;
import hex.compiler.factory.BoolFactory;
import hex.compiler.factory.ClassFactory;
import hex.compiler.factory.ClassInstanceFactory;
import hex.compiler.factory.DomainListenerFactory;
import hex.compiler.factory.DynamicObjectFactory;
import hex.compiler.factory.FloatFactory;
import hex.compiler.factory.FunctionFactory;
import hex.compiler.factory.HashMapFactory;
import hex.compiler.factory.IntFactory;
import hex.compiler.factory.MappingConfigurationFactory;
import hex.compiler.factory.NullFactory;
import hex.compiler.factory.ServiceLocatorFactory;
import hex.compiler.factory.StateTransitionFactory;
import hex.compiler.factory.StaticVariableFactory;
import hex.compiler.factory.StringFactory;
import hex.compiler.factory.UIntFactory;
import hex.compiler.factory.XmlFactory;
import hex.core.HashCodeFactory;
import hex.event.IDispatcher;
import hex.event.IEvent;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.core.ContextTypeList;
import hex.ioc.core.IContextFactory;
import hex.ioc.core.ICoreFactory;
import hex.ioc.core.SymbolTable;
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
import hex.ioc.vo.TransitionVO;
import hex.metadata.IAnnotationProvider;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeContextFactory implements IContextFactory implements ILocatorListener<String, Dynamic>
{
	var _expressions 				: Array<Expr>;
	
	var _annotationProvider			: IAnnotationProvider;
	var _contextDispatcher			: IDispatcher<{}>;
	var _moduleLocator				: ModuleLocator;
	var _applicationContext 		: AbstractApplicationContext;
	var _factoryMap 				: Map<String, FactoryVO->Dynamic>;
	var _coreFactory 				: CompileTimeCoreFactory;
	var _symbolTable 				: SymbolTable;
	var _constructorVOLocator 		: ConstructorVOLocator;
	var _propertyVOLocator 			: PropertyVOLocator;
	var _methodCallVOLocator 		: MethodCallVOLocator;
	var _domainListenerVOLocator 	: DomainListenerVOLocator;
	var _stateTransitionVOLocator 	: StateTransitionVOLocator;
	
	var _transitions				: Array<TransitionVO>;
	
	public function new( expressions : Array<Expr>, applicationContextName : String, applicationContextClass : Class<AbstractApplicationContext> = null  )
	{
		this._expressions = expressions;
		
		//build contextDispatcher
		//var domain : Domain = DomainUtil.getDomain( applicationContextName, Domain );
		//this._contextDispatcher = ApplicationDomainDispatcher.getInstance().getDomainDispatcher( domain );

		/*var injector = new Injector();
		injector.mapToValue( IBasicInjector, injector );
		injector.mapToValue( IDependencyInjector, injector );
		injector.mapToType( IMacroExecutor, MacroExecutor );
		
		//build annotation provider
		this._annotationProvider = new AnnotationProvider();
		this._annotationProvider.registerInjector( injector );
		*/
		
		//build coreFactory
		this._coreFactory = new CompileTimeCoreFactory( this._expressions );
		
		if ( applicationContextClass != null )
		{
			this._applicationContext = new AbstractApplicationContext( this._coreFactory, applicationContextName );
		} 
		else
		{
			this._applicationContext = new AbstractApplicationContext( this._coreFactory, applicationContextName );
		}

		this._init();
	}
	
	public function buildEverything() : Void
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
	
	public function dispatchAssemblingStart() : Void
	{
		#if macro
		var messageType = MacroUtil.getStaticVariable( "hex.ioc.assembler.ApplicationAssemblerMessage.ASSEMBLING_START" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
		#end
		
		/*var AbstractApplicationContextClass = MacroUtil.getPack( Type.getClassName( AbstractApplicationContext ) );
		var ApplicationContextClass = MacroUtil.getPack( Type.getClassName( ApplicationContext ) );
		this._expressions.push( macro @:mergeBlock
		{ 
			applicationContext.getInjector().mapToValue( $p { AbstractApplicationContextClass }, applicationContext );
			applicationContext.getInjector().mapToValue( $p { ApplicationContextClass }, applicationContext );
		} );*/
	}
	
	public function dispatchAssemblingEnd() : Void
	{
		#if macro
		var messageType = MacroUtil.getStaticVariable( "hex.ioc.assembler.ApplicationAssemblerMessage.ASSEMBLING_END" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
		#end
	}
	
	public function dispatchIdleMode() : Void
	{
		#if macro
		var messageType = MacroUtil.getStaticVariable( "hex.ioc.assembler.ApplicationAssemblerMessage.IDLE_MODE" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
		#end
	}
	
	public function registerID( id : String ) : Bool
	{
		return this._symbolTable.register( id );
	}
	
	public function getSymbolTable() : SymbolTable
	{
		return this._symbolTable;
	}
	
	public function registerStateTransitionVO( stateTransitionVO : StateTransitionVO ) : Void
	{
		this._stateTransitionVOLocator.register( stateTransitionVO.ID, stateTransitionVO );
	}
	
	public function buildStateTransition( key : String ) : Array<TransitionVO>
	{
		var transitions : Array<TransitionVO> = null;
		#if macro
		if ( this._stateTransitionVOLocator.isRegisteredWithKey( key ) )
		{
			var stateTransitionVO = this._stateTransitionVOLocator.locate( key );
			stateTransitionVO.expressions = this._expressions;
			transitions = StateTransitionFactory.build( stateTransitionVO, this );
			this._stateTransitionVOLocator.unregister( key );
		}
		#end
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

		#if macro
		var messageType = MacroUtil.getStaticVariable( "hex.ioc.assembler.ApplicationAssemblerMessage.STATE_TRANSITIONS_BUILT" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
		#end
	}
	
	//
	public function registerPropertyVO( propertyVO : PropertyVO ) : Void
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
	
	function _getPropertyValue( property : PropertyVO, id : String ) : Dynamic
	{
		var value 			: Dynamic 	= null;
		var propertyName 	: String 	= property.name;
		
		if ( property.method != null )
		{
			#if macro
			var constructorVO = new ConstructorVO( null, ContextTypeList.FUNCTION, [ property.method ], null, null, false, null, null, null );
			constructorVO.filePosition = property.filePosition;
			value = this._build( constructorVO );
			var extVar = macro $i{ id };
			this._expressions.push( macro @:mergeBlock { $extVar.$propertyName = $value; } );
			#end

		} else if ( property.ref != null )
		{
			#if macro
			var constructorVO = new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, false, property.ref, null, null );
			constructorVO.filePosition = property.filePosition;
			value = this._build( constructorVO );
			var extVar = macro $i{ id };
			var refVar = macro $i{ property.ref };
			this._expressions.push( macro @:mergeBlock { $extVar.$propertyName = $refVar; } );
			#end

		} else if ( property.staticRef != null )
		{
			#if macro
			var constructorVO = new ConstructorVO( null, ContextTypeList.STATIC_VARIABLE, null, null, null, false, null, null,  property.staticRef );
			constructorVO.filePosition = property.filePosition;
			value = this._build( constructorVO );
			var extVar = macro $i{ id };
			this._expressions.push( macro @:mergeBlock { $extVar.$propertyName = $value; } );
			#end

		} else
		{
			#if macro
			var type : String = property.type != null ? property.type : ContextTypeList.STRING;
			var constructorVO = new ConstructorVO( property.ownerID, type, [ property.value ], null, null, false, null, null, null );
			constructorVO.filePosition = property.filePosition;
			value = this._build( constructorVO );
			
			var extVar = macro $i{ id };
			this._expressions.push( macro @:mergeBlock { $extVar.$propertyName = $value; } );
			#end
		}
		
		return value;
	}

	function _setPropertyValue( property : PropertyVO, target : Dynamic, id : String ) : Void
	{
		var propertyName : String = property.name;
		if ( propertyName.indexOf(".") == -1 )
		{
			var value = this._getPropertyValue( property, id );
			Reflect.setProperty( target, propertyName, value );
		}
		else
		{
			var props : Array<String> = propertyName.split( "." );
			propertyName = props.pop();
			var target : Dynamic = this._coreFactory.fastEvalFromTarget( target, props.join(".") );
			Reflect.setProperty( target, propertyName, this._getPropertyValue( property, id ) );
		}
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
	public function registerConstructorVO( constructorVO : ConstructorVO ) : Void
	{
		this._constructorVOLocator.register( constructorVO.ID, constructorVO );
	}
	
	public function buildObject( id : String ) : Void
	{
		#if macro
		if ( this._constructorVOLocator.isRegisteredWithKey( id ) )
		{
			var cons = this._constructorVOLocator.locate( id );	
			var args = cons.arguments;
			if ( args != null )
			{
				if ( cons.className == ContextTypeList.HASHMAP || cons.className == ContextTypeList.SERVICE_LOCATOR || cons.className == ContextTypeList.MAPPING_CONFIG )
				{
					var result = [];
					for ( obj in args )
					{
						var mapVO : MapVO = cast obj;
						mapVO.key = this._build( mapVO.getPropertyKey() );
						mapVO.value = this._build( mapVO.getPropertyValue() );
						result.push( mapVO );
					}
					cons.arguments = result;
				}
				else if ( 	cons.className == ContextTypeList.STRING || 
							cons.className == ContextTypeList.INT || 
							cons.className == ContextTypeList.UINT || 
							cons.className == ContextTypeList.FLOAT || 
							cons.className == ContextTypeList.BOOLEAN || 
							cons.className == ContextTypeList.NULL || 
							cons.className == ContextTypeList.CLASS || 
							cons.className == ContextTypeList.OBJECT )
				{
					var arguments = cons.arguments;
					var l : Int = arguments.length;
					for ( i in 0...l )
					{
						arguments[ i ] = arguments[ i ].arguments[ 0 ];
					}
				}
				else
				{
					var args = [];
					var arguments = cons.arguments;
					var l : Int = arguments.length;
					for ( i in 0...l )
					{
						args.push( this._build( arguments[ i ] ) );
					}
					cons.constructorArgs = args;
				}
			}

			this._build( cons, id );
			this._constructorVOLocator.unregister( id );
		}
		#end
	}
	
	public function buildAllObjects() : Void
	{
		var keys : Array<String> = this._constructorVOLocator.keys();
		for ( key in keys )
		{
			this.buildObject( key );
		}
		
		#if macro
		var messageType = MacroUtil.getStaticVariable( "hex.ioc.assembler.ApplicationAssemblerMessage.OBJECTS_BUILT" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
		
		StateTransitionFactory.flush( this._expressions, this._transitions );
		#end
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

		#if macro
		var messageType = MacroUtil.getStaticVariable( "hex.ioc.assembler.ApplicationAssemblerMessage.DOMAIN_LISTENERS_ASSIGNED" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
		#end
	}

	public function assignDomainListener( id : String ) : Bool
	{
		#if macro
		return DomainListenerFactory.build( this._getFactoryVO( null ), this._domainListenerVOLocator.locate( id ) );
		#else
		return false;
		#end
	}
	
	public function registerMethodCallVO( methodCallVO : MethodCallVO ) : Void
	{
		var index : Int = this._methodCallVOLocator.keys().length +1;
		this._methodCallVOLocator.register( "" + index, methodCallVO );
	}
	
	public function callMethod( id : String ) : Void
	{
		#if macro
		var method 			= this._methodCallVOLocator.locate( id );
		var methodName 		= method.name;
		var cons 			= new ConstructorVO( null, ContextTypeList.FUNCTION, [ method.ownerID + "." + methodName ] );
		var func : Dynamic 	= this._build( cons );
		var arguments 		= method.arguments;

		var idArgs = method.ownerID + "_" + method.name + "Args";
		var varIDArgs = macro $i { idArgs };
		var args = [];

		var l : Int = arguments.length;
		for ( i in 0...l )
		{
			args.push( this._build( arguments[ i ] ) );
		}
		
		var varOwner = macro $i{ method.ownerID };
		this._expressions.push( macro @:mergeBlock { $varOwner.$methodName( $a{ args } ); } );
		#end
	}

	public function callAllMethods() : Void
	{
		var keyList : Array<String> = this._methodCallVOLocator.keys();
		for ( key in keyList )
		{
			this.callMethod(  key );
		}
		
		this._methodCallVOLocator.clear();

		#if macro
		var messageType = MacroUtil.getStaticVariable( "hex.ioc.assembler.ApplicationAssemblerMessage.METHODS_CALLED" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
		#end
	}
	
	public function callModuleInitialisation() : Void
	{
		var modules = this._moduleLocator.values();
		for ( module in modules )
		{
			var module = macro $i { module.getDomain().getName() };
			this._expressions.push( macro @:mergeBlock { $module.initialize(); } );
		}
		
		this._moduleLocator.clear();
		
		#if macro
		var messageType = MacroUtil.getStaticVariable( "hex.ioc.assembler.ApplicationAssemblerMessage.MODULES_INITIALIZED" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
		#end
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
		this._symbolTable.clear();
		
		#if macro
		DomainListenerFactory.domainLocator = null;
		#end
	}

	function _init() : Void
	{
		this._factoryMap 						= new Map();
		this._symbolTable 						= new SymbolTable();
		this._constructorVOLocator 				= new ConstructorVOLocator();
		this._propertyVOLocator 				= new PropertyVOLocator();
		this._methodCallVOLocator 				= new MethodCallVOLocator();
		this._domainListenerVOLocator 			= new DomainListenerVOLocator();
		this._stateTransitionVOLocator 			= new StateTransitionVOLocator( this );
		this._moduleLocator 					= new ModuleLocator( this );
		
		#if macro
		DomainListenerFactory.domainLocator = new Map();
		
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
		this._factoryMap.set( ContextTypeList.STATIC_VARIABLE, StaticVariableFactory.build );
		this._factoryMap.set( ContextTypeList.MAPPING_CONFIG, MappingConfigurationFactory.build );
		#end
		
		this._coreFactory.addListener( this );
	}
	
	#if macro
	function _build( constructorVO : ConstructorVO, ?id : String ) : Dynamic
	{
		constructorVO.isProperty 	= id == null;
		//TODO better type checking with Context.typeof
		var type 					= constructorVO.className;
		var buildMethod 			= ( this._factoryMap.exists( type ) ) ? this._factoryMap.get( type ) : ClassInstanceFactory.build;
		var result 					= buildMethod( this._getFactoryVO( constructorVO ) );

		if ( id != null )
		{
			var extVar = macro $i{ id };
			this._expressions.push( macro @:mergeBlock { coreFactory.register( $v{ id }, $extVar ); } );
			this._coreFactory.register( id, result );
		}

		return result;
	}
	
	function _getFactoryVO( ?constructorVO : ConstructorVO ) : FactoryVO
	{
		var factoryVO 				= new FactoryVO();
		factoryVO.expressions 		= this._expressions;
		
		if ( constructorVO != null )
		{
			factoryVO.type 			= constructorVO.className;
			factoryVO.constructorVO = constructorVO;
		}
		
		factoryVO.contextFactory 	= this;
		factoryVO.coreFactory 		= this._coreFactory;
		factoryVO.moduleLocator 	= this._moduleLocator;

		return factoryVO;
	}
	#end
}