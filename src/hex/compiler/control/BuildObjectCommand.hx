package hex.compiler.control;

import hex.ioc.control.IFactory;
import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildObjectCommand implements IFactory
{
	public function new()
	{

	}

	public function execute( buildHelperVO : FactoryVO ) : Void
	{
		buildHelperVO.constructorVO.result = {};
		
		#if macro
		buildHelperVO.expressions.push( macro @:mergeBlock { lastResult = {}; } );
		#end
	}
}