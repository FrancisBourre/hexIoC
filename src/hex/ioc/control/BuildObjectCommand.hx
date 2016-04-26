package hex.ioc.control;

import hex.ioc.vo.BuildHelperVO;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildObjectCommand implements IBuildCommand
{
	public function new()
	{

	}

	public function execute( buildHelperVO : BuildHelperVO ) : Void
	{
		var constructorVO = buildHelperVO.constructorVO;
		buildHelperVO.constructorVO.result = { };
		
		#if macro
		if ( !constructorVO.isProperty )
		{
			var idVar = constructorVO.ID;
			buildHelperVO.expressions.push( macro @:mergeBlock { var $idVar : Dynamic = $v { {} }; } );
		}
		#end
	}
}