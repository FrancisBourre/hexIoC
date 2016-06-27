package hex.compiler.factory;

import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.ConstructorVO;

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
		
		return macro @:pos( constructorVO.filePosition ) { $a{ constructorVO.constructorArgs } };
	}
	#end
}