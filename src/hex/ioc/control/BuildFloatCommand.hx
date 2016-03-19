package hex.ioc.control;

import hex.ioc.vo.BuildHelperVO;
import hex.error.IllegalArgumentException;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildFloatCommand implements IBuildCommand
{
	public function new()
	{

	}
	
	public function execute( buildHelperVO : BuildHelperVO ) : Void
	{
		var constructorVO : ConstructorVO = buildHelperVO.constructorVO;

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