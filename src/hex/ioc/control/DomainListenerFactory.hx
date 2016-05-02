package hex.ioc.control;

import hex.di.IBasicInjector;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.domain.DomainUtil;
import hex.error.IllegalArgumentException;
import hex.event.ClassAdapter;
import hex.event.EventProxy;
import hex.event.IAdapterStrategy;
import hex.event.MessageType;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.core.ICoreFactory;
import hex.ioc.locator.DomainListenerVOLocator;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.log.Stringifier;
import hex.metadata.IAnnotationProvider;
import hex.module.IModule;
import hex.service.IService;
import hex.service.ServiceConfiguration;
import hex.util.ClassUtil;

/**
 * ...
 * @author Francis Bourre
 */
class DomainListenerFactory
{
	function new()
	{

	}
	
	static public function build( id : String, domainListenerVOLocator : DomainListenerVOLocator, applicationContext : AbstractApplicationContext, annotationProvider : IAnnotationProvider ) : Bool
	{
		var coreFactory : ICoreFactory 					= applicationContext.getCoreFactory();
		var domainListener : DomainListenerVO			= domainListenerVOLocator.locate( id );
		var listener : Dynamic 							= coreFactory.locate( domainListener.ownerID );
		var args : Array<DomainListenerVOArguments> 	= domainListener.arguments;

		// Check if event provider is a service
		var service : IService<ServiceConfiguration> = null;
		if ( coreFactory.isRegisteredWithKey( domainListener.listenedDomainName ) )
		{
			var located : Dynamic = coreFactory.locate( domainListener.listenedDomainName );
			if ( Std.is( located, IService ) )
			{
				service = cast located;
			}
		}

		if ( args != null && args.length > 0 )
		{
			for ( domainListenerArgument in args )
			{
				var method : String = Std.is( listener, EventProxy ) ? "handleCallback" : domainListenerArgument.method;
				
				var messageType : MessageType = domainListenerArgument.name != null ? 
												new MessageType( domainListenerArgument.name ) : 
												ClassUtil.getStaticReference( domainListenerArgument.staticRef );

				if ( ( method != null && Reflect.isFunction( Reflect.field( listener, method ) )) || domainListenerArgument.strategy != null )
				{
					var callback : Dynamic = domainListenerArgument.strategy != null ? DomainListenerFactory._getStrategyCallback( annotationProvider, applicationContext, listener, method, domainListenerArgument.strategy, domainListenerArgument.injectedInModule ) : Reflect.field( listener, method );

					if ( service == null )
					{
						var domain : Domain = DomainUtil.getDomain( domainListener.listenedDomainName, Domain );
						ApplicationDomainDispatcher.getInstance().addHandler( messageType, listener, callback, domain );
					}
					else
					{
						service.addHandler( messageType, listener, callback );
					}
				}
				else
				{
					if ( method == null )
					{
						throw new IllegalArgumentException( "DomainListenerFactory.build failed. Callback should be defined (use 'method' attribute) in instance of '" 
															+ Stringifier.stringify( listener ) + "' class with '" + domainListener.ownerID + "' id" );
					}
					else
					{
						throw new IllegalArgumentException( "DomainListenerFactory.build failed. Method named '" + method + "' can't be found in instance of '" 
															+ Stringifier.stringify( listener ) + "' class with '" + domainListener.ownerID + "' id" );
					}
				}
			}

			return true;

		} else
		{
			var domain : Domain = DomainUtil.getDomain( domainListener.listenedDomainName, Domain );
			return ApplicationDomainDispatcher.getInstance().addListener( listener, domain );
		}
	}
	
	static function _getStrategyCallback( annotationProvider : IAnnotationProvider, applicationContext : AbstractApplicationContext, listener : Dynamic, method : String, strategyClassName : String, injectedInModule : Bool = false ) : Dynamic
	{
		var callback : Dynamic 							= Reflect.field( listener, method );
		var strategyClass : Class<IAdapterStrategy> 	= cast ClassUtil.getClassReference( strategyClassName );
		
		var adapter = new ClassAdapter();
		adapter.setCallBackMethod( listener, callback );
		adapter.setAdapterClass( strategyClass );
		adapter.setAnnotationProvider( annotationProvider );
		
		if ( injectedInModule && Std.is( listener, IModule ) )
		{
			var basicInjector : IBasicInjector = listener.getBasicInjector();
			adapter.setFactoryMethod( basicInjector, basicInjector.instantiateUnmapped );
		}
		else 
		{
			adapter.setFactoryMethod( applicationContext.getBasicInjector(), applicationContext.getBasicInjector().instantiateUnmapped );
		}
		
		var f : Array<Dynamic>->Void = function( rest : Array<Dynamic> ) : Void
		{
			( adapter.getCallbackAdapter() )( rest );
		}
		
		return Reflect.makeVarArgs( f );
	}
}