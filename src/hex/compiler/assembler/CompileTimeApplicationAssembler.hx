package hex.compiler.assembler;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.compiler.core.CompileTimeContextFactory;
import hex.factory.IRequestFactory;
import hex.error.IllegalArgumentException;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.assembler.IApplicationAssembler;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeApplicationAssembler implements IApplicationAssembler
{
	var _mApplicationContext 	= new Map<String, AbstractApplicationContext>();
	var _mContextFactories 		= new Map<AbstractApplicationContext, CompileTimeContextFactory>();
	var _expressions 			= [ macro { } ];
	
	var _assemblerExpression : Expr;

	public function new( assemblerExpression : Expr = null )
	{
		//Create runtime applicationAssembler
		var applicationAssemblerTypePath 	= MacroUtil.getTypePath( Type.getClassName( ApplicationAssembler ) );
		var applicationAssemblerVarName 	= "";
		
		if ( assemblerExpression == null )
		{
			applicationAssemblerVarName = 'applicationAssembler';
			this.addExpression( macro @:mergeBlock { var $applicationAssemblerVarName = new $applicationAssemblerTypePath(); } );
			this._assemblerExpression = macro $i { applicationAssemblerVarName };
		}
		else
		{
			this._assemblerExpression = assemblerExpression;
		}
	}
	
	public function getRequestFactory<T>( applicationContext : AbstractApplicationContext ) : IRequestFactory<T>
	{
		return cast this._mContextFactories.get( applicationContext );
	}
	
	public function getContextFactory( applicationContext : AbstractApplicationContext ) : CompileTimeContextFactory
	{
		return this._mContextFactories.get( applicationContext );
	}
	
	public function buildEverything() : Void
	{
		var itFactory = this._mContextFactories.iterator();
		var contextFactories = [ while ( itFactory.hasNext() ) itFactory.next() ];
		contextFactories.map( function( factory ) { factory.buildEverything(); } );
	}
	
	public function release() : Void
	{
		this._mApplicationContext = new Map();
		this._mContextFactories = new Map();
		this._expressions = [ macro {} ];
	}

	public function getApplicationContext( applicationContextName : String, applicationContextClass : Class<AbstractApplicationContext> = null ) : AbstractApplicationContext
	{
		var applicationContext : AbstractApplicationContext;

		if ( this._mApplicationContext.exists( applicationContextName ) )
		{
			applicationContext = this._mApplicationContext.get( applicationContextName );

		} else
		{
			var builderFactory = new CompileTimeContextFactory( this._expressions, applicationContextName, applicationContextClass );
			applicationContext = builderFactory.getApplicationContext();
			
			this._mApplicationContext.set( applicationContextName, applicationContext);
			this._mContextFactories.set( applicationContext, builderFactory );
		}

		return applicationContext;
	}
	
	public function addExpression( expr : Expr ) : Void
	{
		this._expressions.push( expr );
	}
	
	public function getMainExpression() : Expr
	{
		return return macro $b{ this._expressions };
	}
	
	public function getAssemblerExpression() : Expr
	{
		return this._assemblerExpression;
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