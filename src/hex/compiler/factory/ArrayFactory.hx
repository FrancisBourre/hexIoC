package hex.compiler.factory;

import haxe.macro.Context;
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
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		//build arguments
		ArgumentFactory.build( factoryVO );
		
		var constructorVO = factoryVO.constructorVO;

		if ( !constructorVO.isProperty )
		{
			var idVar 	= constructorVO.ID;
			var exp 	= Context.parseInlineString( "new " + constructorVO.className + "()", constructorVO.filePosition );
			var varType = TypeTools.toComplexType( Context.typeof( exp ) );
			
			factoryVO.expressions.push( macro @:mergeBlock @:pos( constructorVO.filePosition ) { var $idVar : $varType = $a { constructorVO.constructorArgs }; } );
		}
		
		if ( constructorVO.mapTypes != null )
		{
			var instanceVar = macro $i { constructorVO.ID };
			
			var mapTypes = constructorVO.mapTypes;
			for ( mapType in mapTypes )
			{
				//Check if class exists
				FactoryUtil.checkTypeParamsExist( mapType, constructorVO.filePosition );
				
				//Remove whitespaces
				mapType = mapType.split( ' ' ).join( '' );
				
				//Map it
				factoryVO.expressions.push
				( 
					macro @:pos( constructorVO.filePosition ) 
						@:mergeBlock { __applicationContextInjector
							.mapClassNameToValue( $v { mapType }, $instanceVar, $v { constructorVO.ID } ); } 
				);
			}
		}
		
		return macro @:pos( constructorVO.filePosition ) { $a{ constructorVO.constructorArgs } };
	}
	#end
}