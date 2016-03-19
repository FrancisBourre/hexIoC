package hex.ioc.control;

import hex.ioc.vo.BuildHelperVO;
import hex.error.IllegalArgumentException;
import hex.ioc.vo.ConstructorVO;
import hex.log.Logger;

/**
 * ...
 * @author Francis Bourre
 */
class BuildStringCommand implements IBuildCommand
{
	public function new()
	{

	}
	
	public function execute( buildHelperVO : BuildHelperVO ) : Void
	{
		var constructorVO : ConstructorVO = buildHelperVO.constructorVO;

		var value : String 	= null;
		var args 			= constructorVO.arguments;

		if ( args != null && args.length > 0 && args[ 0 ] != null )
		{
			value = Std.string( args[0] );
		}
		else
		{
			throw new IllegalArgumentException(  this + ".execute(" + value + ") returns empty String." );
		}

		if ( value == null )
		{
			value = "";
			#if debug
			Logger.WARN( this + ".execute(" + value + ") returns empty String." );
			#end
		}

		constructorVO.result = value;
	}
}