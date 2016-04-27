package hex.ioc.assembler;

import hex.error.IllegalArgumentException;
import hex.ioc.assembler.IApplicationAssembler;
import hex.ioc.core.ContextFactory;
import hex.ioc.core.ContextTypeList;
import hex.ioc.core.IContextFactory;
import hex.ioc.error.BuildingException;
import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.ioc.vo.MapVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;
import hex.ioc.vo.ServiceLocatorVO;
import hex.ioc.vo.StateTransitionVO;
import hex.util.ClassUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationAssembler implements IApplicationAssembler
{
	public function new() 
	{
		
	}
	
	var _mApplicationContext 		= new Map<String, AbstractApplicationContext>();
	var _mContextFactories 			= new Map<AbstractApplicationContext, IContextFactory>();
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
				throw new IllegalArgumentException( "addConditionalcontext fails with key'" + key + "', this key was already assigned" );
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

	public function getContextFactory( applicationContext : AbstractApplicationContext ) : IContextFactory
	{
		return this._mContextFactories.get( applicationContext );
	}

	public function release() : Void
	{
		var itFactory = this._mContextFactories.iterator();
		while ( itFactory.hasNext() ) itFactory.next().release();
		this._mApplicationContext = new Map();
		this._mContextFactories = new Map();
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
			this.getContextFactory( applicationContext ).registerPropertyVO( ownerID, new PropertyVO( ownerID, name, value, type, ref, method, staticRef ) );
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
						args[ index ] = new MapVO( _getValue( ownerID, obj.key ), _getValue( ownerID, obj.value ) );
					}
				}
				else if ( type == ContextTypeList.SERVICE_LOCATOR )
				{
					for ( index in 0...length )
					{
						obj = args[ index ];
						args[ index ] = new ServiceLocatorVO( _getValue( ownerID, obj.key ), _getValue( ownerID, obj.value ), obj.mapName );
					}
				}
				else
				{
					_deserializeArguments( ownerID, args );
				}
			}

			var constructorVO = new ConstructorVO( ownerID, type, args, factory, singleton, injectInto, null, mapType, staticRef );
			this.getContextFactory( applicationContext ).registerConstructorVO( ownerID, constructorVO );
		}
	}
	
	static function _deserializeArguments( ownerID : String, args : Array<Dynamic> ) : Void
	{
		var length 	: Int = args.length;
		var index 	: Int;
		var obj 	: Dynamic;
		
		for ( index in 0...length )
		{
			args[ index ] = _getValue( ownerID,  args[ index ] );
		}
	}
	
	static function _getValue( ownerID : String, obj : Dynamic ) : ConstructorVO
	{
		if ( obj.method != null )
		{
			return new ConstructorVO( null, ContextTypeList.FUNCTION, [ obj.method ] );

		} else if ( obj.ref != null )
		{
			return new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, false, obj.ref );

		} else if ( obj.staticRef != null )
		{
			return new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, false, null, null, obj.staticRef );

		} else
		{
			var type : String = obj.type != null ? obj.type : ContextTypeList.STRING;
			return new ConstructorVO( ownerID, type, [ obj.value ] );
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
			if ( args != null )
			{
				_deserializeArguments( null, args );
			}

			this.getContextFactory( applicationContext ).registerMethodCallVO( new MethodCallVO( ownerID, methodCallName, args ) );
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
			this.getContextFactory( applicationContext ).registerDomainListenerVO( new DomainListenerVO( ownerID, listenedDomainName, args ) );
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
			this.getContextFactory( applicationContext ).registerStateTransitionVO( ownerID, stateTransition );
		}
	}
	
	public function buildEverything() : Void
	{
		var itFactory = this._mContextFactories.iterator();
		var builderFactories 	: Array<IContextFactory> = [];
		while ( itFactory.hasNext() ) builderFactories.push( itFactory.next() );
		
		var itFactory = this._mContextFactories.iterator();
		while ( itFactory.hasNext() ) itFactory.next().buildAllStateTransitions();
		
		var applicationContexts : Array<AbstractApplicationContext> = [];
		var itContext = this._mApplicationContext.iterator();
		while ( itContext.hasNext() ) applicationContexts.push( itContext.next() );
		
		for ( applicationcontext in applicationContexts )
		{
			applicationcontext._dispatch( ApplicationAssemblerMessage.ASSEMBLING_START );
		}

		var len : Int = builderFactories.length;
		var i 	: Int;
		for ( i in 0...len ) builderFactories[ i ].buildAllObjects();
		for ( i in 0...len ) builderFactories[ i ].assignAllDomainListeners();
		for ( i in 0...len ) builderFactories[ i ].callAllMethods();
		for ( i in 0...len ) builderFactories[ i ].callModuleInitialisation();
		
		for ( applicationcontext in applicationContexts )
		{
			applicationcontext._dispatch( ApplicationAssemblerMessage.ASSEMBLING_END );
		}
	}

	public function getApplicationContext( applicationContextName : String, applicationContextClass : Class<AbstractApplicationContext> = null ) : AbstractApplicationContext
	{
		var applicationContext : AbstractApplicationContext;

		if ( this._mApplicationContext.exists( applicationContextName ) )
		{
			applicationContext = this._mApplicationContext.get( applicationContextName );

		} else
		{
			var builderFactory : IContextFactory = new ContextFactory( applicationContextName, applicationContextClass );
			applicationContext = builderFactory.getApplicationContext();
			
			this._mApplicationContext.set( applicationContextName, applicationContext);
			this._mContextFactories.set( applicationContext, builderFactory );
		}

		return applicationContext;
	}
	
	function _registerID( applicationContext : AbstractApplicationContext, ID : String ) : Bool
	{
		return this.getContextFactory( applicationContext ).registerID( ID );
	}
}