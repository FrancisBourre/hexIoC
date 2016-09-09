package hex.ioc.assembler;

import hex.ioc.assembler.IApplicationAssembler;
import hex.ioc.core.ContextFactory;
import hex.ioc.core.IContextFactory;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;
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
	
	var _mApplicationContext 			= new Map<String, AbstractApplicationContext>();
	var _mContextFactories 				= new Map<AbstractApplicationContext, IContextFactory>();

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
		AnnotationProvider.release();
	}

	public function buildProperty( applicationContext : AbstractApplicationContext, propertyVO : PropertyVO ) : Void
	{
		this.getContextFactory( applicationContext ).registerPropertyVO( propertyVO );
	}

	public function buildObject( applicationContext : AbstractApplicationContext, constructorVO : ConstructorVO ) : Void
	{
		this._registerID( applicationContext, constructorVO.ID );
		this.getContextFactory( applicationContext ).registerConstructorVO( constructorVO );
	}

	public function buildMethodCall( applicationContext : AbstractApplicationContext, methodCallVO : MethodCallVO ) : Void
	{
		this.getContextFactory( applicationContext ).registerMethodCallVO( methodCallVO );
	}

	public function buildDomainListener( applicationContext : AbstractApplicationContext, domainListenerVO : DomainListenerVO ) : Void
	{
		this.getContextFactory( applicationContext ).registerDomainListenerVO( domainListenerVO );
	}
	
	public function configureStateTransition( applicationContext : AbstractApplicationContext, stateTransitionVO : StateTransitionVO ) : Void
	{
		this._registerID( applicationContext, stateTransitionVO.ID );
		this.getContextFactory( applicationContext ).registerStateTransitionVO( stateTransitionVO );
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