package hex.ioc.assembler;

import hex.control.macro.IMacroExecutor;
import hex.control.macro.MacroExecutor;
import hex.core.IApplicationContext;
import hex.di.IBasicInjector;
import hex.di.IDependencyInjector;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.domain.DomainUtil;
import hex.ioc.core.CoreFactory;
import hex.log.DomainLogger;
import hex.log.ILogger;
import hex.metadata.AnnotationProvider;
import hex.metadata.IAnnotationProvider;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextUtil 
{

	function new() 
	{
		
	}
	
	public static function create( applicationContextName : String, applicationContextClass : Class<IApplicationContext> = null ) : IApplicationContext
	{
		//build contextDispatcher
		var domain = DomainUtil.getDomain( applicationContextName, Domain );
		var contextDispatcher = ApplicationDomainDispatcher.getInstance().getDomainDispatcher( domain );
		
		//build injector
		var injector : IDependencyInjector = cast Type.createInstance( Type.resolveClass( 'hex.di.Injector' ), [] );
		injector.mapToValue( IBasicInjector, injector );
		injector.mapToValue( IDependencyInjector, injector );
		injector.mapToType( IMacroExecutor, MacroExecutor );
		
		var logger = new DomainLogger( domain );
		injector.mapToValue( ILogger, logger );
		
		//build annotation provider
		var annotationProvider = AnnotationProvider.getAnnotationProvider( DomainUtil.getDomain( applicationContextName, Domain ) );
		annotationProvider.registerInjector( injector );
		injector.mapToValue( IAnnotationProvider, annotationProvider );
		
		//build coreFactory
		var coreFactory = new CoreFactory( injector, annotationProvider );
		
		//build applicationContext
		var applicationContext : IApplicationContext = null;
		if ( applicationContextClass != null )
		{
			applicationContext = Type.createInstance( applicationContextClass, [ contextDispatcher, coreFactory, applicationContextName ] );
		} 
		else
		{
			//ApplicationContext instantiation
			applicationContext = new ApplicationContext( contextDispatcher, coreFactory, applicationContextName );
		}
		
		//register applicationContext
		injector.mapToValue( IApplicationContext, applicationContext );
		coreFactory.register( applicationContextName, applicationContext );
		
		return applicationContext;
	}
}