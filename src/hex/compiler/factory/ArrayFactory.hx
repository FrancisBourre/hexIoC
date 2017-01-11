package hex.compiler.factory;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;

/**
 * ...
 * @author Francis Bourre
 */
class ArrayFactory
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
		var args 				= ArgumentFactory.build( factoryVO );

		if ( constructorVO.shouldAssign )
		{
			var exp 	= Context.parseInlineString( "new " + constructorVO.type + "()", constructorVO.filePosition );
			var varType = TypeTools.toComplexType( Context.typeof( exp ) );
			var result 	= macro @:pos( constructorVO.filePosition ) var $idVar : $varType = $a{ args };
			
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
						( 
							$v{ mapType }, 
							$i{ constructorVO.ID }, 
							$v{ constructorVO.ID } 
						); 
					};
				}
			}
			
			return result;
		}
		else
		{
			return macro @:pos( constructorVO.filePosition ) $a{ args };
		}
	}
	#end
}