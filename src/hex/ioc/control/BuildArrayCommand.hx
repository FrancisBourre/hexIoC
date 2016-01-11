package hex.ioc.control;

import hex.control.Request;
import hex.ioc.control.AbstractBuildCommand;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildArrayCommand extends AbstractBuildCommand
{
	public function new()
	{
		super();
	}
	
	override public function execute( ?request : Request ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;

		var array : Array<Dynamic> = [];
		var args : Array<Dynamic> = constructorVO.arguments;

		if ( args != null )
		{
			array = args.copy();
		}

		constructorVO.result = array;
	}
}