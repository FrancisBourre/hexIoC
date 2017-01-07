package hex.compiler.factory;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import hex.core.IAnnotationParsable;
import hex.di.IDependencyInjector;
import hex.di.IInjectorContainer;
import hex.domain.Domain;
import hex.domain.DomainExpert;
import hex.domain.DomainUtil;
import hex.error.PrivateConstructorException;
import hex.event.MessageType;
import hex.ioc.vo.FactoryVO;
import hex.log.ILogger;
import hex.metadata.AnnotationProvider;
import hex.module.IModule;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ClassInstanceFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }

	#if macro
	static var _annotationProviderClass 	= MacroUtil.getPack( Type.getClassName( AnnotationProvider ) );
	static var _domainExpertClass 			= MacroUtil.getPack( Type.getClassName( DomainExpert ) );
	static var _domainUtilClass 			= MacroUtil.getPack( Type.getClassName( DomainUtil ) );
	static var _domainClass 				= MacroUtil.getPack( Type.getClassName( Domain ) );
	
	static var _moduleInterface 			= MacroUtil.getClassType( Type.getClassName( IModule ) );
	static var _annotationParsableInterface = MacroUtil.getClassType( Type.getClassName( IAnnotationParsable ) );
	static var _injectorContainerInterface 	= MacroUtil.getClassType( Type.getClassName( IInjectorContainer ) );
					
	static public function build( factoryVO : FactoryVO ) : Expr
	{
		var result : Expr 	= null;
		var constructorVO 	= factoryVO.constructorVO;
		var idVar 			= constructorVO.ID;
		
		if ( constructorVO.ref != null )
		{
			result = ReferenceFactory.build( factoryVO );
		}
		else
		{
			//build arguments
			var constructorArgs = ArgumentFactory.build( factoryVO );
		
			
			var tp 				= MacroUtil.getPack( constructorVO.className, constructorVO.filePosition );
			var typePath 		= MacroUtil.getTypePath( constructorVO.className, constructorVO.filePosition );

			//build instance
			var staticCall 		= constructorVO.staticCall;
			var factoryMethod 	= constructorVO.factory;
			var staticRef 		= constructorVO.staticRef;
			var classType 		= MacroUtil.getClassType( constructorVO.className, constructorVO.filePosition );
			
			if ( constructorVO.injectorCreation && MacroUtil.implementsInterface( classType, _injectorContainerInterface ) )
			{
				result = macro 	@:pos( constructorVO.filePosition ) 
								var $idVar = __applicationContextInjector.instantiateUnmapped( $p { tp } ); 

			}
			else if ( factoryMethod != null )//factory method
			{
				//TODO implement the same behavior @runtime issue#1
				if ( staticRef != null )//static variable - with factory method
				{
					result = macro 	@:pos( constructorVO.filePosition ) 
									var $idVar = $p { tp } .$staticRef.$factoryMethod( $a { constructorArgs } ); 
				}
				else if ( staticCall != null )//static method call - with factory method
				{
					result = macro 	@:pos( constructorVO.filePosition ) 
									var $idVar = $p { tp }.$staticCall().$factoryMethod( $a{ constructorArgs } ); 
				}
				else//factory method error
				{
					Context.error( "'" + factoryMethod + "' method cannot be called on '" + 
					constructorVO.className +"' class. Add static method or variable to make it working.", constructorVO.filePosition );
				}
			}
			else if ( staticCall != null )//simple static method call
			{
				result = macro 	@:pos( constructorVO.filePosition ) 
								var $idVar = $p { tp }.$staticCall( $a{ constructorArgs } ); 
			}
			else//Standard instantiation
			{
				if ( MacroUtil.implementsInterface( classType, _moduleInterface ) )
				{
					var applicationContextName = factoryVO.contextFactory.getApplicationContext().getName();
					
					//TODO register for every instance (from staticCall and/or factory)
					result = macro 	@:mergeBlock 
									{ 
										$p { _domainExpertClass } .getInstance().registerDomain
										( 
											$p { _domainUtilClass } .getDomain( $v { idVar }, $p { _domainClass } ) 
										);

										$p { _annotationProviderClass } .registerToParentDomain
										( 
											$p{ _domainUtilClass } .getDomain( $v{ idVar }, $p{ _domainClass } ),
											$p{ _domainUtilClass } .getDomain( $v{ applicationContextName }, $p{ _domainClass } )
										); 
									} 
					
					factoryVO.moduleLocator.register( constructorVO.ID, new EmptyModule( constructorVO.ID ) );
				}
				
				var varType = 
					TypeTools.toComplexType( 
						Context.typeof( 
							Context.parseInlineString( '( null : ${constructorVO.type})', constructorVO.filePosition ) ) );
				
				var exp = macro @:pos( constructorVO.filePosition )
								@:mergeBlock 
								{ 
									var $idVar : $varType = new $typePath( $a { constructorArgs } ); 
								};
								
				result = result == null ? exp:
					macro 	@:pos( constructorVO.filePosition )
							@:mergeBlock 
							{ 
								$result; 
								$exp; 
							};
							
				if ( constructorVO.injectInto && MacroUtil.implementsInterface( classType, _injectorContainerInterface ) )
				{
					var instanceVar = macro $i { idVar };
					
					//TODO throws an error if interface is not implemented
					result = macro 	@:pos( constructorVO.filePosition )
									@:mergeBlock
									{ 
										$result; 
										__applicationContextInjector.injectInto( $instanceVar ); 
									};
				}
				
				if ( MacroUtil.implementsInterface( classType, _annotationParsableInterface ) )
				{
					result = macro 	@:pos( constructorVO.filePosition ) 
									@:mergeBlock 
									{ 
										$result; 
										$i{ "__annotationProvider" }.parse( $i{ idVar } ); 
									};
				}
			}
			
			//Mapping
			if ( constructorVO.mapTypes != null )
			{
				var mapTypes = constructorVO.mapTypes;
				for ( mapType in mapTypes )
				{
					//Check if class exists
					FactoryUtil.checkTypeParamsExist( mapType, constructorVO.filePosition );
					
					//Remove whitespaces
					mapType = mapType.split( ' ' ).join( '' );
					
					//Map it
					result = macro 	@:pos( constructorVO.filePosition ) 
					@:mergeBlock 
					{
						$result; 
						__applicationContextInjector.mapClassNameToValue
						( $v{ mapType }, $i{ idVar }, $v{ idVar } 
						);
					};
				}
			}
		}
		
		return macro @:pos( constructorVO.filePosition ) $result;
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