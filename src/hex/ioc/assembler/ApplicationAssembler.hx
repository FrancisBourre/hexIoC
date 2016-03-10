package hex.ioc.assembler;

import hex.collection.HashMap;
import hex.control.macro.IMacroExecutor;
import hex.control.macro.MacroExecutor;
import hex.core.HashCodeFactory;
import hex.di.IBasicInjector;
import hex.di.IDependencyInjector;
import hex.error.IllegalArgumentException;
import hex.inject.Injector;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.assembler.IApplicationAssembler;
import hex.ioc.core.BuilderFactory;
import hex.ioc.core.ContextTypeList;
import hex.ioc.core.CoreFactory;
import hex.ioc.core.IBuilderFactory;
import hex.ioc.core.ICoreFactory;
import hex.ioc.error.BuildingException;
import hex.ioc.locator.MethodCallVOLocator;
import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.ioc.vo.MapVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;
import hex.ioc.vo.ServiceLocatorVO;
import hex.ioc.vo.StateTransitionVO;
import hex.metadata.AnnotationProvider;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationAssembler implements IApplicationAssembler
{
	public function new() 
	{
		
	}
	
	var _mApplicationContext 		= new HashMap<String, AbstractApplicationContext>();
	var _mBuilderFactories 			= new HashMap<AbstractApplicationContext, IBuilderFactory>();
	var _conditionalProperties 		= new Map<String, Bool>();
	var _strictMode					: Bool = true;
	
	public function setStrictMode( b : Bool ) : Void
	{
		this._strictMode = b;
	}
	
	public function isInStrictMode() : Bool
	{
		return this._strictMode;
	}
	
	public function addConditionalProperty( conditionalProperties : Map<String, Bool> ) : Void
	{
		var i = conditionalProperties.keys();
		var key : String;
		while ( i.hasNext() )
		{
			key = i.next();
			if ( !this._conditionalProperties.exists( key ) )
			{
				this._conditionalProperties.set( key, conditionalProperties.get( key ) );
			}
			else
			{
				throw new IllegalArgumentException( "addConditionalcontext fails with key'" + key + "', this keywas already assigned" );
			}
		}
	}
	
	public function allowsIfList( ifList : Array<String> = null ) : Bool
	{
		if ( ifList != null )
		{
			for ( ifItem in ifList )
			{
				if ( this._conditionalProperties.exists( ifItem ) )
				{
					if ( this._conditionalProperties.get( ifItem ) )
					{
						return true;
					}
				}
				else if ( this._strictMode )
				{
					throw new BuildingException( "'" + ifItem + "' was not found in application assembler" );
				}
			}
		}
		else
		{
			return true;
		}
		
		return false;
	}
	
	public function allowsIfNotList( ifNotList : Array<String> = null ) : Bool
	{
		if ( ifNotList != null )
		{
			for ( ifNotItem in ifNotList )
			{
				if ( this._conditionalProperties.exists( ifNotItem ) )
				{
					if ( this._conditionalProperties.get( ifNotItem ) )
					{
						return false;
					}
				}
				else if ( this._strictMode )
				{
					throw new BuildingException( "'" + ifNotItem + "' was not found in application assembler" );
				}
			}
		}
		
		return true;
	}

	public function getBuilderFactory( applicationContext : AbstractApplicationContext ) : IBuilderFactory
	{
		return this._mBuilderFactories.get( applicationContext );
	}

	public function release() : Void
	{
		var builderFactories : Array<IBuilderFactory> = this._mBuilderFactories.getValues();
		for ( builderFactory in builderFactories )
		{
			builderFactory.release();
		}
		this._mApplicationContext.clear();
		this._mBuilderFactories.clear();
	}

	public function buildProperty(  applicationContext 	: AbstractApplicationContext,
									ownerID 			: String,
									name 				: String = null,
									value 				: String = null,
									type 				: String = null,
									ref 				: String = null,
									method 				: String = null,
									staticRef 			: String = null,
									ifList 				: Array<String> = null, 
									ifNotList 			: Array<String> = null ) : Void
	{
		if ( this.allowsIfList( ifList ) && this.allowsIfNotList( ifNotList ) )
		{
			this.getBuilderFactory( applicationContext ).getPropertyVOLocator().addProperty( ownerID, name, value, type, ref, method, staticRef );
		}
	}

	public function buildObject(    applicationContext 	: AbstractApplicationContext,
									ownerID 			: String,
									type 				: String = null,
									args 				: Array<Dynamic> = null,
									factory 			: String = null,
									singleton 			: String = null,
									injectInto 			: Bool = false,
									mapType 			: String = null,
									staticRef 			: String = null,
									ifList 				: Array<String> = null, 
									ifNotList 			: Array<String> = null ) : Void
	{
		if ( this.allowsIfList( ifList ) && this.allowsIfNotList( ifNotList ) )
		{
			this._registerID( applicationContext, ownerID );
			
			if ( args != null )
			{
				var length : Int = args.length;
				var index : Int;
				var obj : Dynamic;

				if ( type == ContextTypeList.HASHMAP )
				{
					for ( index in 0...length )
					{
						obj = args[ index ];
						var keyDic 		: Dynamic 		= obj.key;
						var valueDic 	: Dynamic 		= obj.value;
						var pKeyDic 	: PropertyVO 	= this.getBuilderFactory( applicationContext ).getPropertyVOLocator().buildProperty( ownerID, keyDic.name, keyDic.value, keyDic.type, keyDic.ref, keyDic.method, keyDic.staticRef );
						var pValueDic 	: PropertyVO 	= this.getBuilderFactory( applicationContext ).getPropertyVOLocator().buildProperty( ownerID, valueDic.name, valueDic.value, valueDic.type, valueDic.ref, valueDic.method, valueDic.staticRef );
						args[ index ] 					= new MapVO( pKeyDic, pValueDic );
					}
				}
				else if ( type == ContextTypeList.SERVICE_LOCATOR )
				{
					for ( index in 0...length )
					{
						obj = args[ index ];
						var keySC 		: Dynamic 		= obj.key;
						var valueSC 	: Dynamic 		= obj.value;
						var pKeySC 		: PropertyVO 	= this.getBuilderFactory( applicationContext ).getPropertyVOLocator().buildProperty( ownerID, keySC.name, keySC.value, keySC.type, keySC.ref, keySC.method, keySC.staticRef );
						var pValueSC 	: PropertyVO 	= this.getBuilderFactory( applicationContext ).getPropertyVOLocator().buildProperty( ownerID, valueSC.name, valueSC.value, valueSC.type, valueSC.ref, valueSC.method, valueSC.staticRef );
						args[ index ] 					= new ServiceLocatorVO( pKeySC, pValueSC, obj.mapName );
					}
				}
				else
				{
					for ( index in 0...length )
					{
						obj = args[ index ];
						var propertyVO : PropertyVO = this.getBuilderFactory( applicationContext ).getPropertyVOLocator().buildProperty( ownerID, obj.name, obj.value, obj.type, obj.ref, obj.method, obj.staticRef );
						args[ index ] = propertyVO;
					}
				}
			}

			var constructorVO = new ConstructorVO( ownerID, type, args, factory, singleton, injectInto, null, mapType, staticRef );
			this.getBuilderFactory( applicationContext ).getConstructorVOLocator().register( ownerID, constructorVO );
		}
	}

	public function buildMethodCall( 	applicationContext 	: AbstractApplicationContext, 
										ownerID 			: String, 
										methodCallName 		: String, 
										args 				: Array<Dynamic> = null,
										ifList 				: Array<String> = null, 
										ifNotList 			: Array<String> = null ) : Void
	{
		if ( this.allowsIfList( ifList ) && this.allowsIfNotList( ifNotList ) )
		{
			var methodCallVOLocator : MethodCallVOLocator = this.getBuilderFactory( applicationContext ).getMethodCallVOLocator();

			if ( args != null )
			{
				var length : Int = args.length;
				for ( i in 0...length )
				{
					var obj : Dynamic = args[ i ];
					var prop = new PropertyVO( obj.id, obj.name, obj.value, obj.type, obj.ref, obj.method, obj.staticRef );
					args[ i ] = prop;
				}
			}

			var method = new MethodCallVO( ownerID, methodCallName, args );
			var index : Int = methodCallVOLocator.keys().length +1;
			methodCallVOLocator.register( "" + index, method );
		}
	}

	public function buildDomainListener( 	applicationContext 	: AbstractApplicationContext, 
											ownerID 			: String, 
											listenedDomainName 	: String, 
											args 				: Array<DomainListenerVOArguments> = null,
											ifList 				: Array<String> = null, 
											ifNotList 			: Array<String> = null ) : Void
	{
		if ( this.allowsIfList( ifList ) && this.allowsIfNotList( ifNotList ) )
		{
			var domainListenerVO = new DomainListenerVO( ownerID, listenedDomainName, args );
			this.getBuilderFactory( applicationContext ).getDomainListenerVOLocator().register( "" + HashCodeFactory.getKey( domainListenerVO ), domainListenerVO );
		}
	}
	
	public function configureStateTransition( 	applicationContext 	: AbstractApplicationContext, 
												ownerID 			: String, 
												staticReference 	: String, 
												instanceReference 	: String, 
												enterList 			: Array<CommandMappingVO>, 
												exitList 			: Array<CommandMappingVO>,
												ifList 				: Array<String> = null, 
												ifNotList 			: Array<String> = null ) : Void
	{
		if ( this.allowsIfList( ifList ) && this.allowsIfNotList( ifNotList ) )
		{
			this._registerID( applicationContext, ownerID );
			var stateTransition = new StateTransitionVO( ownerID, staticReference, instanceReference, enterList, exitList );
			this.getBuilderFactory( applicationContext ).getStateTransitionVOLocator().register( ownerID, stateTransition );
		}
	}
	
	public function buildEverything() : Void
	{
		var builderFactories 	: Array<IBuilderFactory> 	= this._mBuilderFactories.getValues();
		var len 				: Int 						= builderFactories.length;
		var i 					: Int;
		
		for ( i in 0...len ) ApplicationAssembler._buildAllStateTransitions( builderFactories[ i ] );
		
		var applicationContexts : Array<AbstractApplicationContext> = null;
		
		applicationContexts = this._mApplicationContext.getValues();
		for ( applicationcontext in applicationContexts )
		{
			applicationcontext._dispatch( ApplicationAssemblerMessage.ASSEMBLING_START );
		}

		for ( i in 0...len ) ApplicationAssembler._buildAllObjects( builderFactories[ i ] );
		for ( i in 0...len ) ApplicationAssembler._assignAllDomainListeners( builderFactories[ i ] );
		for ( i in 0...len ) ApplicationAssembler._callAllMethods( builderFactories[ i ] );
		for ( i in 0...len ) ApplicationAssembler._callInitOnModules( builderFactories[ i ] );
		
		applicationContexts = this._mApplicationContext.getValues();
		for ( applicationcontext in applicationContexts )
		{
			applicationcontext._dispatch( ApplicationAssemblerMessage.ASSEMBLING_END );
		}
	}

	public function getApplicationContext( applicationContextName : String, applicationContextClass : Class<AbstractApplicationContext> = null ) : AbstractApplicationContext
	{
		var applicationContext : AbstractApplicationContext;

		if ( this._mApplicationContext.containsKey( applicationContextName ) )
		{
			applicationContext = this._mApplicationContext.get( applicationContextName );

		} else
		{
			//build injector
			var injector = new Injector();
			injector.mapToValue( IBasicInjector, injector );
			injector.mapToValue( IDependencyInjector, injector );
			injector.mapToType( IMacroExecutor, MacroExecutor );
			
			//assign AnnotationProvider
			AnnotationProvider.getInstance( injector );
		
			//build coreFactory
			var coreFactory : ICoreFactory = new CoreFactory( injector );
			
			if ( applicationContextClass != null )
			{
				applicationContext = Type.createInstance( applicationContextClass, [ coreFactory, applicationContextName ] );
			} 
			else
			{
				//ApplicationContext instantiation
				applicationContext = new ApplicationContext( coreFactory, applicationContextName );
			}
			
			//register applicationContext
			injector.mapToValue( ApplicationContext, applicationContext );
			coreFactory.register( applicationContextName, applicationContext );
			
			var builderFactory : IBuilderFactory 	= new BuilderFactory();
			builderFactory.init( applicationContext, coreFactory );
			
			this._mApplicationContext.put( applicationContextName, applicationContext );
			this._mBuilderFactories.put( applicationContext, builderFactory );
			applicationContext._dispatch( ApplicationAssemblerMessage.CONTEXT_PARSED );
		}

		return applicationContext;
	}
	
	function _registerID( applicationContext : AbstractApplicationContext, ID : String ) : Bool
	{
		return this.getBuilderFactory( applicationContext ).getIDExpert().register( ID );
	}
	
	static function _buildAllStateTransitions( builderFactory : IBuilderFactory ) : Void
	{
		builderFactory.getStateTransitionVOLocator().build();
		builderFactory.getApplicationContext()._dispatch( ApplicationAssemblerMessage.STATE_TRANSITIONS_BUILT );
	}

	static function _buildAllObjects( builderFactory : IBuilderFactory ) : Void
	{
		builderFactory.getConstructorVOLocator().buildAllObjects();
		builderFactory.getApplicationContext()._dispatch( ApplicationAssemblerMessage.OBJECTS_BUILT );
	}

	static function _assignAllDomainListeners( builderFactory : IBuilderFactory ) : Void
	{
		builderFactory.getDomainListenerVOLocator().assignAllDomainListeners();
		builderFactory.getApplicationContext()._dispatch( ApplicationAssemblerMessage.DOMAIN_LISTENERS_ASSIGNED );
	}

	static function _callAllMethods( builderFactory : IBuilderFactory ) : Void
	{
		builderFactory.getMethodCallVOLocator().callAllMethods();
		builderFactory.getApplicationContext()._dispatch( ApplicationAssemblerMessage.METHODS_CALLED );
	}
	
	static function _callInitOnModules( builderFactory : IBuilderFactory ) : Void
	{
		builderFactory.getModuleLocator().callModuleInitialisation();
		builderFactory.getApplicationContext()._dispatch( ApplicationAssemblerMessage.MODULES_INITIALIZED );
	}
}