package hex.compiler.factory;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import haxe.macro.TypeTools;
import hex.compiletime.basic.vo.FactoryVOTypeDef;
import hex.compiletime.factory.ArgumentFactory;
import hex.di.IInjectorContainer;
import hex.domain.Domain;
import hex.domain.DomainExpert;
import hex.error.PrivateConstructorException;
import hex.module.IContextModule;
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

	static var _domainExpertClass 		: Array<String>;
	static var _domainClass 			: Array<String>;
	
	static var _moduleInterface 			: ClassType;
	static var _injectorContainerInterface 	: ClassType;
	
	static var _isInitialized = false;
	
	static function _init() : Bool
	{
		ClassInstanceFactory._domainExpertClass 			= MacroUtil.getPack( Type.getClassName( DomainExpert ) );
		ClassInstanceFactory._domainClass 					= MacroUtil.getPack( Type.getClassName( Domain ) );
		ClassInstanceFactory._moduleInterface 				= MacroUtil.getClassType( Type.getClassName( IContextModule ) );
		ClassInstanceFactory._injectorContainerInterface 	= MacroUtil.getClassType( Type.getClassName( IInjectorContainer ) );

		return true;
	}
					
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		if ( !ClassInstanceFactory._isInitialized ) ClassInstanceFactory._isInitialized = ClassInstanceFactory._init();

		var result : Expr 	= null;
		var constructorVO 	= factoryVO.constructorVO;
		var idVar 			= constructorVO.ID;

		//build arguments
		var constructorArgs = ArgumentFactory.build( factoryVO );
	
		var tp 				= MacroUtil.getPack( constructorVO.className, constructorVO.filePosition );
		var typePath 		= MacroUtil.getTypePath( constructorVO.className, constructorVO.filePosition );

		//build instance
		var staticCall 		= constructorVO.staticCall;
		var factoryMethod 	= constructorVO.factory;
		var staticRef 		= constructorVO.staticRef;
		var classType 		= MacroUtil.getClassType( constructorVO.className, constructorVO.filePosition );
		
		var getNullArgsArray = function( length : UInt ) return  [ for ( i in 0...length ) macro null ];
		
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
				//Assign right type description
				try 
				{
					constructorVO.type = MacroUtil.getFQCNFromExpression( macro $p { tp } .$staticRef.$factoryMethod( $a { constructorArgs } ) );
				}
				catch( e : Dynamic )
				{
					//TODO Find a better way
					var args = getNullArgsArray( constructorArgs.length );
					constructorVO.type = MacroUtil.getFQCNFromExpression( macro $p { tp } .$staticRef.$factoryMethod( $a { args } ) );
				}

				result = macro 	@:pos( constructorVO.filePosition ) 
								var $idVar = $p { tp } .$staticRef.$factoryMethod( $a { constructorArgs } ); 
			}
			else if ( staticCall != null )//static method call - with factory method
			{
				//Assign right type description
				try 
				{
					constructorVO.type = MacroUtil.getFQCNFromExpression( macro $p { tp } .$staticCall().$factoryMethod( $a { constructorArgs } ) );
				}
				catch( e : Dynamic )
				{
					//TODO Find a better way
					var args = getNullArgsArray( constructorArgs.length );
					constructorVO.type = MacroUtil.getFQCNFromExpression( macro $p { tp } .$staticCall().$factoryMethod( $a { args } ) );
				}
			
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
			//Assign right type description
			try 
			{
				constructorVO.type = MacroUtil.getFQCNFromExpression( macro $p { tp } .$staticCall( $a { constructorArgs } ) );
			}
			catch( e : Dynamic )
			{
				//TODO Find a better way
				var args = getNullArgsArray( constructorArgs.length );
				constructorVO.type = MacroUtil.getFQCNFromExpression( macro $p { tp } .$staticCall( $a { args } ) );
			}
			
			result = macro 	@:pos( constructorVO.filePosition ) 
							var $idVar = $p { tp }.$staticCall( $a{ constructorArgs } ); 
		}
		else//Standard instantiation
		{
			if ( MacroUtil.implementsInterface( classType, _moduleInterface ) )
			{
				var applicationContextName = factoryVO.contextFactory.getApplicationContext().getName();
				
				//concatenate domain's name with parent's domain
				var domainName = factoryVO.contextFactory.getApplicationContext().getDomain().getName() 
					+ '.' + idVar;
				
				//TODO register for every instance (from staticCall and/or factory)
				result = macro 	@:mergeBlock 
								{ 
									$p { _domainExpertClass } .getInstance().registerDomain
									( 
										$p { _domainClass } .getDomain( $v { domainName } ) 
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
		
		return macro @:pos( constructorVO.filePosition ) $result;
	}
}
#end