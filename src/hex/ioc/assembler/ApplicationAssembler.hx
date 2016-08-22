package hex.ioc.assembler;

import hex.ioc.assembler.IApplicationAssembler;
import hex.ioc.core.ContextFactory;
import hex.ioc.core.ContextTypeList;
import hex.ioc.core.IContextFactory;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;
import hex.ioc.vo.StateTransitionVO;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationAssembler implements IApplicationAssembler
{
	public function new() 
	{
		
	}
	
	var _mApplicationContext 			= new Map<String, AbstractApplicationContext>();
	var _mContextFactories 				= new Map<AbstractApplicationContext, IContextFactory>();
	var _conditionalVariablesChecker 	= new ConditionalVariablesChecker();

	public function setStrictMode( b : Bool ) : Void
	{
		this._conditionalVariablesChecker.setStrictMode( b );
	}
	
	public function isInStrictMode() : Bool
	{
		return this._conditionalVariablesChecker.isInStrictMode();
	}
	
	public function addConditionalProperty( conditionalProperties : Map<String, Bool> ) : Void
	{
		this._conditionalVariablesChecker.addConditionalProperty( conditionalProperties );
	}
	
	public function allowsIfList( ifList : Array<String> = null ) : Bool
	{
		return this._conditionalVariablesChecker.allowsIfList( ifList );
	}
	
	public function allowsIfNotList( ifNotList : Array<String> = null ) : Bool
	{
		return this._conditionalVariablesChecker.allowsIfNotList( ifNotList );
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
		this._conditionalVariablesChecker = new ConditionalVariablesChecker();
	}

	public function buildProperty( applicationContext : AbstractApplicationContext, propertyVO : PropertyVO ) : Void
	{
		if ( this.allowsIfList( propertyVO.ifList ) && this.allowsIfNotList( propertyVO.ifNotList ) )
		{
			this.getContextFactory( applicationContext ).registerPropertyVO( propertyVO );
		}
	}

	public function buildObject( applicationContext : AbstractApplicationContext, constructorVO : ConstructorVO ) : Void
	{
		if ( this.allowsIfList( constructorVO.ifList ) && this.allowsIfNotList( constructorVO.ifNotList ) )
		{
			this._registerID( applicationContext, constructorVO.ID );
			this.getContextFactory( applicationContext ).registerConstructorVO( constructorVO );
		}
	}
	
	static function _deserializeArguments( ownerID : String, args : Array<Dynamic> ) : Void
	{
		var length 	: Int = args.length;
		var index 	: Int;
		var obj 	: Dynamic;
		
		for ( index in 0...length )
		{
			args[ index ] = _getConstructorVO( ownerID,  args[ index ] );
		}
	}
	
	static function _getConstructorVO( ownerID : String, obj : Dynamic ) : ConstructorVO
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

	public function buildMethodCall( applicationContext : AbstractApplicationContext, methodCallVO : MethodCallVO ) : Void
	{
		if ( this.allowsIfList( methodCallVO.ifList ) && this.allowsIfNotList( methodCallVO.ifNotList ) )
		{
			this.getContextFactory( applicationContext ).registerMethodCallVO( methodCallVO );
		}
	}

	public function buildDomainListener( applicationContext : AbstractApplicationContext, domainListenerVO : DomainListenerVO ) : Void
	{
		if ( this.allowsIfList( domainListenerVO.ifList ) && this.allowsIfNotList( domainListenerVO.ifNotList ) )
		{
			this.getContextFactory( applicationContext ).registerDomainListenerVO( domainListenerVO );
		}
	}
	
	public function configureStateTransition( applicationContext : AbstractApplicationContext, stateTransitionVO : StateTransitionVO ) : Void
	{
		if ( this.allowsIfList( stateTransitionVO.ifList ) && this.allowsIfNotList( stateTransitionVO.ifNotList ) )
		{
			this._registerID( applicationContext, stateTransitionVO.ID );
			this.getContextFactory( applicationContext ).registerStateTransitionVO( stateTransitionVO );
		}
	}
	
	public function buildEverything() : Void
	{
		var itFactory = this._mContextFactories.iterator();
		var contextFactories = [ while ( itFactory.hasNext() ) itFactory.next() ];
		
		contextFactories.map( function( factory ) { factory.buildAllStateTransitions(); } );
		contextFactories.map( function( factory ) { factory.dispatchAssemblingStart(); } );
		contextFactories.map( function( factory ) { factory.buildAllObjects(); } );
		contextFactories.map( function( factory ) { factory.assignAllDomainListeners(); } );
		contextFactories.map( function( factory ) { factory.callAllMethods(); } );
		contextFactories.map( function( factory ) { factory.callModuleInitialisation(); } );
		contextFactories.map( function( factory ) { factory.dispatchAssemblingEnd(); } );
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
	
	inline function _registerID( applicationContext : AbstractApplicationContext, ID : String ) : Bool
	{
		return this.getContextFactory( applicationContext ).registerID( ID );
	}
}