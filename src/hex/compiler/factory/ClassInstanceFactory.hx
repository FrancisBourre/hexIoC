package hex.compiler.factory;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import haxe.macro.TypeTools;
import hex.compiler.vo.FactoryVO;
import hex.di.IInjectorContainer;
import hex.domain.Domain;
import hex.domain.DomainExpert;
import hex.domain.DomainUtil;
import hex.error.PrivateConstructorException;
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
        throw new PrivateConstructorException();
    }

	static var _annotationProviderClass 	: Array<String>;
	static var _domainExpertClass 			: Array<String>;
	static var _domainUtilClass 			: Array<String>;
	static var _domainClass 				: Array<String>;
	
	static var _moduleInterface 			: ClassType;
	static var _injectorContainerInterface 	: ClassType;
	
	static var _isInitialized = false;
	
	static function _init() : Bool
	{
		ClassInstanceFactory._annotationProviderClass 		= MacroUtil.getPack( Type.getClassName( AnnotationProvider ) );
		ClassInstanceFactory._domainExpertClass 			= MacroUtil.getPack( Type.getClassName( DomainExpert ) );
		ClassInstanceFactory._domainUtilClass 				= MacroUtil.getPack( Type.getClassName( DomainUtil ) );
		ClassInstanceFactory._domainClass 					= MacroUtil.getPack( Type.getClassName( Domain ) );
		ClassInstanceFactory._moduleInterface 				= MacroUtil.getClassType( Type.getClassName( IModule ) );
		ClassInstanceFactory._injectorContainerInterface 	= MacroUtil.getClassType( Type.getClassName( IInjectorContainer ) );

		return true;
	}
					
	static public function build( factoryVO : FactoryVO ) : Expr
	{
		if ( !ClassInstanceFactory._isInitialized ) ClassInstanceFactory._isInitialized = ClassInstanceFactory._init();

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
					Context.error( 	"'" + factoryMethod + "' method cannot be called on '" +  constructorVO.className + 
									"' class. Add static method or variable to make it working.", constructorVO.filePosition );
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
				}
				
				var varType = 
					TypeTools.toComplexType( 
						Context.typeof( 
							Context.parseInlineString( '( null : ${constructorVO.type})', constructorVO.filePosition ) ) );
				
				var exp = macro @:pos( constructorVO.filePosition )
									var $idVar : $varType = new $typePath( $a { constructorArgs } ); 
								
				result = result == null ? exp:
					macro 	@:pos( constructorVO.filePosition )
							@:mergeBlock 
							{ 
								$result; 
								$exp; 
							};
			}
		}
		
		return macro @:pos( constructorVO.filePosition ) $result;
	}
}
#end