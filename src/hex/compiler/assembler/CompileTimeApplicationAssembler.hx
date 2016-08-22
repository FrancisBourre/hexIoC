#if macro
package hex.compiler.assembler;

import haxe.macro.Context;
import haxe.macro.Expr;
import hex.compiler.core.CompileTimeContextFactory;
import hex.error.IllegalArgumentException;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.IApplicationAssembler;
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
class CompileTimeApplicationAssembler implements IApplicationAssembler
{
	var _mApplicationContext 	= new Map<String, AbstractApplicationContext>();
	var _mContextFactories 		= new Map<AbstractApplicationContext, IContextFactory>();
	var _expressions 			= [ macro {} ];

	public function new()
	{
		
	}
	
	public function addExpression( expr : Expr ) : Void
	{
		this._expressions.push( expr );
	}
	
	public function getMainExpression() : Expr
	{
		return return macro $b{ this._expressions };
	}
	
	public function getContextFactory( applicationContext : AbstractApplicationContext ) : IContextFactory
	{
		return this._mContextFactories.get( applicationContext );
	}

	public function release() : Void
	{
		this._mApplicationContext = new Map();
		this._mContextFactories = new Map();
		this._expressions = [ macro {} ];
	}

	public function buildProperty( applicationContext : AbstractApplicationContext, propertyVO : PropertyVO ) : Void
	{
		this.getContextFactory( applicationContext ).registerPropertyVO( propertyVO );
	}
	
	public function buildObject( applicationContext : AbstractApplicationContext, constructorVO : ConstructorVO ) : Void
	{
		this._registerID( applicationContext, constructorVO.ID, constructorVO.filePosition );
		this.getContextFactory( applicationContext ).registerConstructorVO( constructorVO );
	}

	public function buildMethodCall ( applicationContext : AbstractApplicationContext, methodCallVO : MethodCallVO ) : Void
	{
		this.getContextFactory( applicationContext ).registerMethodCallVO( methodCallVO );
	}

	public function buildDomainListener( applicationContext : AbstractApplicationContext, domainListenerVO : DomainListenerVO ) : Void
	{
		this.getContextFactory( applicationContext ).registerDomainListenerVO( domainListenerVO );
	}

	public function configureStateTransition( applicationContext : AbstractApplicationContext, stateTransitionVO : StateTransitionVO ) : Void
	{
		this._registerID( applicationContext, stateTransitionVO.ID, stateTransitionVO.filePosition );
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
			var builderFactory : IContextFactory = new CompileTimeContextFactory( this._expressions, applicationContextName, applicationContextClass );
			applicationContext = builderFactory.getApplicationContext();
			
			this._mApplicationContext.set( applicationContextName, applicationContext);
			this._mContextFactories.set( applicationContext, builderFactory );
		}

		return applicationContext;
	}
	
	function _registerID( applicationContext : AbstractApplicationContext, ID : String, filePosition : Position ) : Bool
	{
		try
		{
			return this.getContextFactory( applicationContext ).registerID( ID );
		}
		catch ( e : IllegalArgumentException )
		{
			Context.error( "Id '" + ID + "' is already registered in applicationContext named '" + applicationContext.getName() + "'", filePosition );
		}
		
		return false;
	}
}
#end