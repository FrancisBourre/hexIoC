package hex.ioc.control;

import hex.control.Request;
import hex.error.IllegalArgumentException;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildFloatCommand extends AbstractBuildCommand
{
	public function new()
	{
		super();
	}
	
	override public function execute( ?request : Request ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;

		var args : Array<Dynamic> 	= constructorVO.arguments;
		var number : Float 	= Math.NaN;

		if ( args != null && args.length > 0 ) 
		{
			number = Std.parseFloat( args[ 0 ] );
		}

		if ( !Math.isNaN( number ) )
		{
			constructorVO.result = number;
		}
		else
		{
			throw new IllegalArgumentException( this + ".execute(" + number + ") failed." );
		}
	}
}