package hex.compiler.factory;

import haxe.macro.Context;
import haxe.macro.Expr;
import hex.config.stateful.ServiceLocator;
import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ServiceLocatorFactory
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
		
		var typePath 			= MacroUtil.getTypePath( Type.getClassName( ServiceLocator ) );
		var e 					= macro @:pos( constructorVO.filePosition ) { new $typePath(); };

		if ( constructorVO.shouldAssign )
		{
			var result 	= macro @:pos( constructorVO.filePosition ) var $idVar = $e;
			
			if ( args.length <= 0 )
			{
				#if debug
				Context.warning( "Empty ServiceLocator built.", constructorVO.filePosition );
				#end

			} else
			{
				for ( item in args )
				{
					if ( item.key != null )
					{
						var a = [ item.key, item.value, macro { $v{ item.mapName } } ];
						
						//Fill with arguments
						result = macro 	@:pos( constructorVO.filePosition ) 
						@:mergeBlock 
						{
							$result; 
							$i{ idVar }.addService( $a{ a } );
						}

					} else
					{
						#if debug
						Context.warning( "'null' key for value '"  + item.value +"' added.", constructorVO.filePosition );
						#end
					}
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