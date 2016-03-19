package hex.ioc.control;

import hex.ioc.vo.BuildHelperVO;
import hex.error.IllegalArgumentException;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildBooleanCommand implements IBuildCommand
{
	public function new()
	{

	}
	
	public function execute( buildHelperVO : BuildHelperVO ) : Void
	{
		var constructorVO : ConstructorVO = buildHelperVO.constructorVO;

		var value : String 	= "";
		var args 			= constructorVO.arguments;

		if ( args != null && args.length > 0 ) 
		{
			value = args[0];
		}
		
		if ( value == "true" )
		{
			constructorVO.result = true;
		}
		else if ( value == "false" )
		{
			constructorVO.result = false;
		}
		else
		{
			throw new IllegalArgumentException( this + ".build(" + value + ") failed." );
		}
	}
}