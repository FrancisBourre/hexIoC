package hex.ioc.assembler;

import hex.factory.IRequestFactory;
import hex.ioc.assembler.IApplicationAssembler;
import hex.ioc.core.ContextFactory;
import hex.ioc.core.IContextFactory;
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
	var _mContextFactories 				= new Map<AbstractApplicationContext, ContextFactory>();
	
	public function getRequestFactory<T>( applicationContext : AbstractApplicationContext ) : IRequestFactory<T>
	{
		return cast this._mContextFactories.get( applicationContext );
	}
	
	public function getContextFactory( applicationContext : AbstractApplicationContext ) : ContextFactory
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
		var itFactory = this._mContextFactories.iterator();
		while ( itFactory.hasNext() ) itFactory.next().release();
		
		this._mApplicationContext = new Map();
		this._mContextFactories = new Map();
		AnnotationProvider.release();
	}
	
	public function getApplicationContext( applicationContextName : String, applicationContextClass : Class<AbstractApplicationContext> = null ) : AbstractApplicationContext
	{
		var applicationContext : AbstractApplicationContext;

		if ( this._mApplicationContext.exists( applicationContextName ) )
		{
			applicationContext = this._mApplicationContext.get( applicationContextName );

		} else
		{
			var builderFactory = new ContextFactory( applicationContextName, applicationContextClass );
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