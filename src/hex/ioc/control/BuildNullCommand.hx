package hex.ioc.control;

import hex.control.Request;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildNullCommand extends AbstractBuildCommand
{
	public function new()
	{
		super();
	}
	
	override public function execute( ?request : Request ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;
		constructorVO.result = null;
	}
}