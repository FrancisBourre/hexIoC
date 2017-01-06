package hex.compiler.factory;

import haxe.macro.Context;
import haxe.macro.Expr;
import hex.error.PrivateConstructorException;
import hex.ioc.di.MappingConfiguration;
import hex.ioc.vo.FactoryVO;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class MappingConfigurationFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }

	#if macro
	static public function build( factoryVO : FactoryVO ) : Expr
	{
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		var args 				= MapArgumentFactory.build( factoryVO );
		
		var typePath 			= MacroUtil.getTypePath( Type.getClassName( MappingConfiguration ) );
		var e 					= macro @:pos( constructorVO.filePosition ) { new $typePath(); };

		if ( constructorVO.shouldAssign )
		{
			var result 	= macro @:pos( constructorVO.filePosition ) var $idVar = $e;
			
			if ( args.length == 0 )
			{
				#if debug
				Context.warning( "Empty MappingConfiguration built.", constructorVO.filePosition );
				#end

			} else
			{
				for ( item in args )
				{
					if ( item.key != null )
					{
						var a = [ item.key, item.value, macro { $v{ item.mapName } }, macro { $v{ item.asSingleton } }, macro { $v{ item.injectInto } } ];

						//Fill with arguments
						result = macro 	@:pos( constructorVO.filePosition ) 
						@:mergeBlock 
						{
							$result; 
							$i{ idVar }.addMapping( $a{ a } );
						}
						
					} else
					{
						#if debug
						Context.warning( "'null' key for value '"  + item.value +"' added.", constructorVO.filePosition );
						#end
					}
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
			
			return result;
		}
		else
		{
			return macro @:pos( constructorVO.filePosition ) $e;
		}
	}
	#end
}