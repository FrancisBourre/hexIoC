package hex.ioc.assembler;

import hex.core.IApplicationAssembler;
import hex.core.IApplicationContext;
import hex.core.IBuilder;
import hex.ioc.core.ContextFactory;
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
	
	var _mApplicationContext 			= new Map<String, IApplicationContext>();
	var _mContextFactories 				= new Map<IApplicationContext, ContextFactory>();
	
	public function getBuilder<T>( applicationContext : IApplicationContext ) : IBuilder<T>
	{
		return cast this._mContextFactories.get( applicationContext );
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
	
	public function getApplicationContext( applicationContextName : String, applicationContextClass : Class<IApplicationContext> = null ) : IApplicationContext
	{
		var applicationContext : IApplicationContext;

		if ( this._mApplicationContext.exists( applicationContextName ) )
		{
			applicationContext = this._mApplicationContext.get( applicationContextName );

		} else
		{
			var contextFactory = new ContextFactory( applicationContextName, applicationContextClass );
			applicationContext = contextFactory.getApplicationContext();
			
			this._mApplicationContext.set( applicationContextName, applicationContext);
			this._mContextFactories.set( applicationContext, contextFactory );
		}

		return applicationContext;
	}
}