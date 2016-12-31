package hex.ioc.control;

import hex.di.IBasicInjector;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.domain.DomainUtil;
import hex.error.IllegalArgumentException;
import hex.event.ClassAdapter;
import hex.event.EventProxy;
import hex.event.IAdapterStrategy;
import hex.event.IObservable;
import hex.event.MessageType;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.core.ICoreFactory;
import hex.ioc.locator.DomainListenerVOLocator;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.log.Stringifier;
import hex.metadata.IAnnotationProvider;
import hex.module.IModule;
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
		var coreFactory 								= applicationContext.getCoreFactory();
		var domainListener : DomainListenerVO			= domainListenerVOLocator.locate( id );
		var listener : Dynamic 							= coreFactory.locate( domainListener.ownerID );
		var args : Array<DomainListenerVOArguments> 	= domainListener.arguments;

		// Check if event provider is observable
		var observable : IObservable = null;
		if ( coreFactory.isRegisteredWithKey( domainListener.listenedDomainName ) )
		{
			var located : Dynamic = coreFactory.locate( domainListener.listenedDomainName );
			if ( Std.is( located, IObservable ) )
			{
				observable = cast located;
			}
		}

		if ( args != null && args.length > 0 )
		{
			for ( domainListenerArgument in args )
			{
				var method : String = Std.is( listener, EventProxy ) ? "handleCallback" : domainListenerArgument.method;
				var messageType : MessageType = ClassUtil.getStaticVariableReference( domainListenerArgument.staticRef );

				if ( ( method != null && Reflect.isFunction( Reflect.field( listener, method ) )) || domainListenerArgument.strategy != null )
				{
					var callback : Dynamic = domainListenerArgument.strategy != null ? DomainListenerFactory._getStrategyCallback( annotationProvider, applicationContext, listener, method, domainListenerArgument.strategy, domainListenerArgument.injectedInModule ) : Reflect.field( listener, method );

					if ( observable == null )
					{
						var domain : Domain = DomainUtil.getDomain( domainListener.listenedDomainName, Domain );
						ApplicationDomainDispatcher.getInstance().addHandler( messageType, listener, callback, domain );
					}
					else
					{
						var f : Array<Dynamic>->Void = function( rest : Array<Dynamic> ) : Void
						{
							Reflect.callMethod( listener, callback, rest );
						}
						observable.addHandler( messageType, Reflect.makeVarArgs( f ) );
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
		var callback : Dynamic = null;
		if ( method != null ) 
		{
			callback = Reflect.field( listener, method );
		}
		
		var strategyClass : Class<IAdapterStrategy> 	= cast ClassUtil.getClassReference( strategyClassName );
		
		var adapter = new ClassAdapter();
		adapter.setCallBackMethod( listener, callback );
		adapter.setAdapterClass( strategyClass );
		adapter.setAnnotationProvider( annotationProvider );
		
		if ( injectedInModule && Std.is( listener, IModule ) )
		{
			var basicInjector : IBasicInjector = listener.getInjector();
			adapter.setFactoryMethod( basicInjector, basicInjector.instantiateUnmapped );
		}
		else 
		{
			adapter.setFactoryMethod( applicationContext.getInjector(), applicationContext.getInjector().instantiateUnmapped );
		}
		
		var f : Array<Dynamic>->Void = function( rest : Array<Dynamic> ) : Void
		{
			( adapter.getCallbackAdapter() )( rest );
		}
		
		return Reflect.makeVarArgs( f );
	}
}