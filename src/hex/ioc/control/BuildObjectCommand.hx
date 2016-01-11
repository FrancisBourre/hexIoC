package hex.ioc.control;

import hex.control.Request;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildObjectCommand extends AbstractBuildCommand
{
	override public function execute( ?request : Request ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;
		constructorVO.result = {};
	}
}