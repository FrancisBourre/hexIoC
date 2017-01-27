package hex.compiler.factory;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import hex.collection.Locator;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.domain.DomainUtil;
import hex.event.ClassAdapter;
import hex.event.EventProxy;
import hex.event.IObservable;
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
	public static var domainLocator : Map<String, String>;
	
	static var _eventProxyClassType 				= MacroUtil.getClassType( Type.getClassName( EventProxy ) );
	static var _observableInterface 				= MacroUtil.getClassType( Type.getClassName( IObservable ) );
	
	static var _applicationDomainDispatcherClass 	= MacroUtil.getPack( Type.getClassName( ApplicationDomainDispatcher )  );
	static var _domainUtilClass 					= MacroUtil.getPack( Type.getClassName( DomainUtil )  );
	static var _domainClass 						= MacroUtil.getPack( Type.getClassName( Domain )  );
	
	static var _classAdapterTypePath 				= MacroUtil.getTypePath( Type.getClassName( ClassAdapter ) );
	
	static function _getDomain( expressions: Array<Expr>, domainName : String, factoryVO : FactoryVO ) : String
	{
		if ( domainLocator.exists( domainName ) )
		{
			return domainLocator.get( domainName );
		}
		else
		{
			var domainVariable = "__domainName_" + domainName;

			expressions.push( macro @:mergeBlock 
			{ 
				var $domainVariable = $p { _domainUtilClass }.getDomain( $v{ domainName }, $p { _domainClass } ); 
			} );
			
			domainLocator.set( domainName, domainVariable );
			return domainVariable;
		}
	}
	
	//TODO refactor with reification
	static function _getClassTypeFromNewBlockExpression( e : Expr ) : ClassType
	{
		var className : String = "";

		if ( e != null )
		{
			switch ( e.expr )
			{
				case EVars( vars ):
				
					switch( vars[ 0 ].expr.expr )
					{
						case ENew( t, params ):
							className = t.pack.join( "." ) + "." + t.name;

						default:
							return null;
					}
				
				default:
					return null;
			}

			return MacroUtil.getClassType( className );
		}
		else
		{
			return null;
		}
	}
	
	static function isEventProxy( e : Expr ) : Bool
	{
		var classType = DomainListenerFactory._getClassTypeFromNewBlockExpression( e );
		return classType != null ? MacroUtil.isSameClass( classType, DomainListenerFactory._eventProxyClassType ) || MacroUtil.isSubClassOf( classType, DomainListenerFactory._eventProxyClassType ) : false;
	}
	
	static function isObservable( e : Expr ) : Bool
	{
		var classType = DomainListenerFactory._getClassTypeFromNewBlockExpression( e );
		return classType != null ? MacroUtil.implementsInterface( classType, DomainListenerFactory._observableInterface ) : false;
	}
	
	static public function build( expressions : Array<Expr>, factoryVO : FactoryVO, domainListener : DomainListenerVO, moduleLocator : Locator<String, String> ) : Bool
	{
		var args = domainListener.arguments;

		if ( args != null && args.length > 0 )
		{
			for ( domainListenerArgument in args )
			{
				var method = DomainListenerFactory.isEventProxy( factoryVO.coreFactory.locate( domainListener.ownerID ) ) ? "handleCallback" : domainListenerArgument.method;

				if ( method != null || domainListenerArgument.strategy != null )
				{
					var listenerID 			= domainListener.ownerID;
					var listenerVar 		= macro $i{ listenerID };
					var listenedDomainName 	= domainListener.listenedDomainName;
					var messageType 		= MacroUtil.getStaticVariable( domainListenerArgument.staticRef, domainListenerArgument.filePosition );
					var strategyClassName 	= domainListenerArgument.strategy;
					
					if ( !factoryVO.coreFactory.isRegisteredWithKey( listenedDomainName ) )
					{
						Context.error( "Domain '" + listenedDomainName + "' not found in applicationContext named '" + 
						factoryVO.contextFactory.getApplicationContext().getName() + "'", domainListener.filePosition );
					}
					var listenedDomain		= factoryVO.coreFactory.locate( listenedDomainName );

					if ( strategyClassName != null )
					{
						var StrategyClass = MacroUtil.getPack( strategyClassName, domainListenerArgument.filePosition );
						
						var adapterVarName = "__adapterFor__" + listenedDomainName + "__" + ( domainListenerArgument.staticRef.split( "." ).join( "_" ) );
						expressions.push( macro @:mergeBlock { var $adapterVarName = new $_classAdapterTypePath(); } );
						var adapterVar = macro $i { adapterVarName };
						
						if ( method != null )
						{
							expressions.push( macro @:mergeBlock @:pos( domainListenerArgument.filePosition ) { $adapterVar.setCallBackMethod( $listenerVar, $listenerVar.$method ); } );
						}

						expressions.push( macro @:mergeBlock { $adapterVar.setAdapterClass( $p { StrategyClass } ); } );
						expressions.push( macro @:mergeBlock { $adapterVar.setAnnotationProvider( __annotationProvider ); } );

						if ( domainListenerArgument.injectedInModule && moduleLocator.isRegisteredWithKey( listenerID ) )
						{
							expressions.push( macro @:mergeBlock 
							{ 
								$adapterVar.setFactoryMethod( $listenerVar.getInjector(), $listenerVar.getInjector().instantiateUnmapped ); 
							} );
						}
						else 
						{
							expressions.push( macro @:mergeBlock 
							{ 
								$adapterVar.setFactoryMethod( __applicationContextInjector, __applicationContextInjector.instantiateUnmapped ); 
							} );
						}
						
						var adapterExp = macro { Reflect.makeVarArgs( function( rest : Array<Dynamic> ) : Void { ( $adapterVar.getCallbackAdapter() )( rest ); } ); };
						
						if ( DomainListenerFactory.isObservable( listenedDomain ) )
						{
							var dispatcherVar = macro $i{ listenedDomainName };
							expressions.push( macro @:mergeBlock { $dispatcherVar.addHandler( $messageType, $adapterExp ); } );
						}
						else
						{
							var domainVar = macro $i { DomainListenerFactory._getDomain( expressions, listenedDomainName, factoryVO ) };
							expressions.push( macro @:mergeBlock 
							{ 
								$p { _applicationDomainDispatcherClass } .getInstance()
								.addHandler( $messageType, $listenerVar, $adapterExp, $domainVar ); 
							} );
						}
					}
					else
					{
						if ( DomainListenerFactory.isObservable( listenedDomain ) )
						{
							var dispatcherVar = macro @:pos( domainListenerArgument.filePosition ) $i{ listenedDomainName };
							expressions.push( macro @:mergeBlock 
							{ 
								$dispatcherVar.addHandler( $messageType, $listenerVar.$method ); 
							} );
						}
						else
						{
							var domainVar = macro $i { DomainListenerFactory._getDomain( expressions, listenedDomainName, factoryVO ) };
							var messageType = MacroUtil.getStaticVariable( domainListenerArgument.staticRef, domainListenerArgument.filePosition );
							expressions.push( macro @:pos( domainListenerArgument.filePosition ) @:mergeBlock { $p { _applicationDomainDispatcherClass } .getInstance().addHandler( $messageType, $listenerVar, $listenerVar.$method, $domainVar ); } );
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

			var domainVar = macro $i { DomainListenerFactory._getDomain( expressions, listenedDomainName, factoryVO ) };
			expressions.push( macro @:mergeBlock { $p { _applicationDomainDispatcherClass }.getInstance().addListener( $extVar, $domainVar ); } );

			return true;
		}
	}
	#end
}