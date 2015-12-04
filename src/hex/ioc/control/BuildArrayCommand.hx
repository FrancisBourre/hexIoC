package hex.ioc.control;

import hex.error.IllegalArgumentException;
import hex.event.IEvent;
import hex.ioc.control.AbstractBuildCommand;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildArrayCommand extends AbstractBuildCommand
{
	override public function execute( ?e : IEvent ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;

		var array : Array<Dynamic>;
		var args : Array<Dynamic> = constructorVO.arguments;

		if ( args == null )
		{
			array = [];
		}
		else
		{
			array = args.copy();
		}

		if ( array.length == 0 )
		{
			var errorMessage : String = this + ".build(" + args + ") returns an empty Array.";
			throw new IllegalArgumentException( errorMessage );
		}

		constructorVO.result = array;
	}
}