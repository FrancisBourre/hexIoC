package hex.compiler.factory;

import haxe.macro.Expr;
import hex.di.IBasicInjector;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.domain.DomainUtil;
import hex.error.IllegalArgumentException;
import hex.event.ClassAdapter;
import hex.event.EventProxy;
import hex.event.IAdapterStrategy;
import hex.event.IObservable;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.core.ICoreFactory;
import hex.ioc.locator.DomainListenerVOLocator;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.ioc.vo.FactoryVO;
import hex.log.Stringifier;
import hex.metadata.IAnnotationProvider;
import hex.module.IModule;
import hex.util.ClassUtil;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class DomainListenerFactory
{
	function new()
	{

	}
	
	#if macro
	static public function build( factoryVO : FactoryVO, id : String, domainListenerVOLocator : DomainListenerVOLocator, applicationContext : AbstractApplicationContext, annotationProvider : IAnnotationProvider ) : Dynamic
	{
		var ApplicationDomainDispatcherClass = MacroUtil.getPack( Type.getClassName( ApplicationDomainDispatcher )  );
		var DomainUtilClass = MacroUtil.getPack( Type.getClassName( DomainUtil )  );
		var DomainClass = MacroUtil.getPack( Type.getClassName( Domain )  );
			
		var coreFactory : ICoreFactory 					= applicationContext.getCoreFactory();
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
				//var messageType : MessageType = ClassUtil.getStaticVariableReference( domainListenerArgument.staticRef );

				if ( ( method != null /*&& Reflect.isFunction( Reflect.field( listener, method ) )*/) || domainListenerArgument.strategy != null )
				{
					var callback : Dynamic = domainListenerArgument.strategy != null ? DomainListenerFactory._getStrategyCallback( annotationProvider, applicationContext, listener, method, domainListenerArgument.strategy, domainListenerArgument.injectedInModule ) : Reflect.field( listener, method );

					if ( observable != null )
					{
						//TODO implements observable publishers
						//observable.addHandler( messageType, listener, callback );
					}
					else
					{
						var listenerID 			= domainListenerVOLocator.locate( id ).ownerID;
						var listenedDomainName 	= domainListener.listenedDomainName;
						var extVar 				= macro $i{ listenerID };
						var messageType 		= MacroUtil.getStaticVariable( domainListenerArgument.staticRef );
						
						//TODO optimize calls to DomainUtil
						factoryVO.expressions.push( macro @:mergeBlock { $p { ApplicationDomainDispatcherClass }.getInstance().addHandler( $messageType, $extVar, $extVar.$method, $p { DomainUtilClass }.getDomain( $v{ listenedDomainName }, $p { DomainClass } ) ); } );
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
			var listenerID = domainListenerVOLocator.locate( id ).ownerID;
			var listenedDomainName = domainListener.listenedDomainName;
			var extVar = macro $i{ listenerID };
			
			//TODO optimize calls to DomainUtil
			factoryVO.expressions.push( macro @:mergeBlock { $p { ApplicationDomainDispatcherClass }.getInstance().addListener( $extVar, $p { DomainUtilClass }.getDomain( $v{ listenedDomainName }, $p { DomainClass } ) ); } );

			return true;
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
	#end
}