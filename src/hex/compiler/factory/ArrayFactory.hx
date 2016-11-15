package hex.compiler.factory;

import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ArrayFactory
{
	function new()
	{

	}
	
	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;
		//var e =  macro @:pos( constructorVO.filePosition ) { $a { constructorVO.constructorArgs }; };
		
		if ( !constructorVO.isProperty )
		{
			var idVar = constructorVO.ID;
			factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $a{ constructorVO.constructorArgs }; } );
		}
		
		if ( constructorVO.mapTypes != null )
		{
			var instanceVar = macro $i { constructorVO.ID };
			
			var mapTypes = constructorVO.mapTypes;
			for ( mapType in mapTypes )
			{
				//Check if class exists
				MacroUtil.getPack( mapType.split( '<' )[ 0 ], constructorVO.filePosition );
				
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