package hex.ioc.control;

import hex.ioc.vo.BuildHelperVO;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildNullCommand implements IBuildCommand
{
	public function new()
	{

	}
	
	public function execute( buildHelperVO : BuildHelperVO ) : Void
	{
		var constructorVO : ConstructorVO = buildHelperVO.constructorVO;
		constructorVO.result = null;
		
		#if macro
		if ( !constructorVO.isProperty )
		{
			var idVar = constructorVO.ID;
			buildHelperVO.expressions.push( macro @:mergeBlock { var $idVar = null; } );
		}
		#end
	}
}