package hex.compiler.factory;

import haxe.macro.Context;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.domain.DomainUtil;
import hex.event.ClassAdapter;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.ioc.vo.FactoryVO;
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
	static public function build( factoryVO : FactoryVO, domainListener : DomainListenerVO ) : Dynamic
	{
		var ApplicationDomainDispatcherClass = MacroUtil.getPack( Type.getClassName( ApplicationDomainDispatcher )  );
		var DomainUtilClass = MacroUtil.getPack( Type.getClassName( DomainUtil )  );
		var DomainClass = MacroUtil.getPack( Type.getClassName( Domain )  );
		
		var args : Array<DomainListenerVOArguments> = domainListener.arguments;

		if ( args != null && args.length > 0 )
		{
			for ( domainListenerArgument in args )
			{
				//TODO implement EventProxy
				//var method : String = Std.is( listener, EventProxy ) ? "handleCallback" : domainListenerArgument.method;
				var method = domainListenerArgument.method;

				if ( method != null || domainListenerArgument.strategy != null )
				{
					var listenerID 			= domainListener.ownerID;
					var listenerVar 		= macro $i{ listenerID };
					var listenedDomainName 	= domainListener.listenedDomainName;
					var messageType 		= MacroUtil.getStaticVariable( domainListenerArgument.staticRef );
					var strategyClassName 	= domainListenerArgument.strategy;

					if ( strategyClassName != null )
					{
						
						var StrategyClass = MacroUtil.getPack( strategyClassName );
						var ClassAdapterClass = MacroUtil.getTypePath( Type.getClassName( ClassAdapter ) );
						
						var adapterVarName = "__adapterFor__" + listenedDomainName + "__" + ( domainListenerArgument.staticRef.split( "." ).join( "_" ) );
						factoryVO.expressions.push( macro @:mergeBlock { var $adapterVarName = new $ClassAdapterClass(); } );
						var adapterVar = macro $i { adapterVarName };
						
						if ( method != null )
						{
							factoryVO.expressions.push( macro @:mergeBlock { $adapterVar.setCallBackMethod( $listenerVar, $listenerVar.$method ); } );
						}

						factoryVO.expressions.push( macro @:mergeBlock { $adapterVar.setAdapterClass( $p { StrategyClass } ); } );
						factoryVO.expressions.push( macro @:mergeBlock { $adapterVar.setAnnotationProvider( __annotationProvider ); } );

						if ( domainListenerArgument.injectedInModule && factoryVO.moduleLocator.isRegisteredWithKey( listenerID ) )
						{
							factoryVO.expressions.push( macro @:mergeBlock 
							{ 
								$adapterVar.setFactoryMethod( $listenerVar.getInjector(), $listenerVar.getInjector().instantiateUnmapped ); 
							} );
						}
						else 
						{
							factoryVO.expressions.push( macro @:mergeBlock 
							{ 
								$adapterVar.setFactoryMethod( __applicationContextInjector, __applicationContextInjector.instantiateUnmapped ); 
							} );
						}
						
						var adapterExp = macro { Reflect.makeVarArgs( function( rest : Array<Dynamic> ) : Void { ( $adapterVar.getCallbackAdapter() )( rest ); } ); };
						
						if ( factoryVO.observableLocator.isRegisteredWithKey( listenedDomainName ) )
						{
							var dispatcherVar = macro $i{ listenedDomainName };
							factoryVO.expressions.push( macro @:mergeBlock { $dispatcherVar.addHandler( $messageType, $listenerVar, $adapterExp ); } );
						}
						else
						{
							//TODO optimize calls to DomainUtil
							factoryVO.expressions.push( macro @:mergeBlock 
							{ 
								$p { ApplicationDomainDispatcherClass } .getInstance()
								.addHandler( $messageType, $listenerVar, $adapterExp, 
								$p { DomainUtilClass }.getDomain( $v{ listenedDomainName }, $p { DomainClass } ) ); 
							} );
						}
					}
					else
					{
						if ( factoryVO.observableLocator.isRegisteredWithKey( listenedDomainName ) )
						{
							//TODO remove ObservableLocator
							var dispatcherVar = macro $i{ listenedDomainName };
							factoryVO.expressions.push( macro @:mergeBlock 
							{ 
								$dispatcherVar.addHandler( $messageType, $listenerVar, $listenerVar.$method ); 
							} );
						}
						else
						{
							//TODO optimize calls to DomainUtil
							var messageType = MacroUtil.getStaticVariable( domainListenerArgument.staticRef );
							factoryVO.expressions.push( macro @:mergeBlock { $p { ApplicationDomainDispatcherClass }.getInstance().addHandler( $messageType, $listenerVar, $listenerVar.$method, $p { DomainUtilClass }.getDomain( $v{ listenedDomainName }, $p { DomainClass } ) ); } );
						}
					}
				}
				else
				{
					if ( method == null )
					{
						Context.error( "DomainListenerFactory.build failed. Callback should be defined (use 'method' attribute) in node with '" + domainListener.ownerID + "' id", Context.currentPos() );
					}
					else
					{
						Context.error( "DomainListenerFactory.build failed. Method named '" + method + "' can't be found in node with '" + domainListener.ownerID + "' id", Context.currentPos() );
					}
				}
			}

			return true;

		} else
		{
			var listenerID = domainListener.ownerID;
			var listenedDomainName = domainListener.listenedDomainName;
			var extVar = macro $i{ listenerID };
			
			//TODO optimize calls to DomainUtil
			factoryVO.expressions.push( macro @:mergeBlock { $p { ApplicationDomainDispatcherClass }.getInstance().addListener( $extVar, $p { DomainUtilClass }.getDomain( $v{ listenedDomainName }, $p { DomainClass } ) ); } );

			return true;
		}
	}
	#end
}