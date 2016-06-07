package hex.compiler.factory;
import haxe.macro.Expr;
import hex.di.IDependencyInjector;
import hex.domain.Domain;
import hex.domain.DomainExpert;
import hex.domain.DomainUtil;
import hex.event.MessageType;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.log.ILogger;
import hex.module.IModule;
import hex.util.MacroUtil;


/**
 * ...
 * @author Francis Bourre
 */
class ClassInstanceFactory
{
	function new()
	{

	}

	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;
		var e : Expr = null;
		
		if ( constructorVO.ref != null )
		{
			e = ReferenceFactory.build( factoryVO );
		}
		else
		{
			var idVar = constructorVO.ID;
			var tp = MacroUtil.getPack( constructorVO.type );
			var typePath = MacroUtil.getTypePath( constructorVO.type );

			//build instance
			var singleton = constructorVO.singleton;
			var factory = constructorVO.factory;
			if ( factory != null )
			{
				if ( singleton != null )
				{
					e = macro { $p { tp }.$singleton().$factory( $a{ constructorVO.constructorArgs } ); };
					factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $e; } );
				}
				else
				{
					e = macro { $p { tp }.$factory( $a{ constructorVO.constructorArgs } ); };
					factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $e; } );
				}
			
			}
			else if ( singleton != null )
			{
				e = macro { $p { tp }.$singleton(); };
				factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $e; } );
			}
			else
			{
				var classType = MacroUtil.getClassType( constructorVO.type );
				var moduleInterface = MacroUtil.getClassType( "hex.module.IModule" );
				var observableInterface = MacroUtil.getClassType( "hex.event.IObservable" );
				
				if ( MacroUtil.implementsInterface( classType, observableInterface ) )
				{
					factoryVO.observableLocator.register( constructorVO.ID, true );
				}
				
				if ( MacroUtil.implementsInterface( classType, moduleInterface ) )
				{
					//TODO register to AnnotationProvider
					//AnnotationProvider.registerToDomain( factoryVO.contextFactory.getAnnotationProvider(), DomainUtil.getDomain( constructorVO.ID, Domain ) );
					
					var DomainExpertClass = MacroUtil.getPack( Type.getClassName( DomainExpert )  );
					var DomainUtilClass = MacroUtil.getPack( Type.getClassName( DomainUtil )  );
					var DomainClass = MacroUtil.getPack( Type.getClassName( Domain )  );
					
					//TODO register for every instance (from singleton and/or factory)
					//TODO optimize calls to DomainUtil
					factoryVO.expressions.push( macro @:mergeBlock { $p { DomainExpertClass } .getInstance().registerDomain( $p { DomainUtilClass } .getDomain( $v { idVar }, $p { DomainClass } ) ); } );
					factoryVO.moduleLocator.register( constructorVO.ID, new EmptyModule( constructorVO.ID ) );
				}
				
				e = macro { new $typePath( $a{ constructorVO.constructorArgs } ); };
				factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $e; } );
				
				var annotationParsableInterface = MacroUtil.getClassType( "hex.core.IAnnotationParsable" );
				if ( MacroUtil.implementsInterface( classType, annotationParsableInterface ) )
				{
					var instanceVar = macro $i { idVar };
					var annotationProviderVar = macro $i { "__annotationProvider" };
					factoryVO.expressions.push( macro @:mergeBlock { $annotationProviderVar.parse( $instanceVar ); } );
				}
			}

			if ( constructorVO.mapType != null )
			{
				var instanceVar = macro $i { idVar };
				var classToMap = MacroUtil.getPack( constructorVO.mapType );
				factoryVO.expressions.push( macro @:mergeBlock { __applicationContextInjector.mapToValue( $p{ classToMap }, $instanceVar, $v { idVar } ); } );
			}
		}
		
		return e;
	}
	#end
}

private class EmptyModule implements IModule
{
	var _domainName : String;
	
	public function new( domainName : String )
	{
		this._domainName = domainName;
	}
	
	public function initialize() : Void 
	{
		
	}
	
	public var isInitialized( get, null ) : Bool;
	
	function get_isInitialized() : Bool 
	{
		return false;
	}
	
	public function release() : Void 
	{
		
	}
	
	public var isReleased( get, null ) : Bool;
	
	function get_isReleased() : Bool 
	{
		return false;
	}
	
	public function dispatchPublicMessage( messageType : MessageType, ?data : Array<Dynamic> ) : Void 
	{
		
	}
	
	public function addHandler( messageType : MessageType, scope : Dynamic, callback : Dynamic ) : Void 
	{
		
	}
	
	public function removeHandler( messageType : MessageType, scope : Dynamic, callback : Dynamic ) : Void 
	{
		
	}
	
	public function getDomain() : Domain 
	{
		return DomainUtil.getDomain( this._domainName, Domain );
	}
	
	public function getLogger() : ILogger 
	{
		return null;
	}
	
	public function getInjector() : IDependencyInjector 
	{
		return null;
	}
}