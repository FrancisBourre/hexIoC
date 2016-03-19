package hex.ioc.control;

import hex.ioc.vo.BuildHelperVO;
import hex.error.IllegalArgumentException;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildClassCommand implements IBuildCommand
{
	public function new()
	{

	}
	
	public function execute( buildHelperVO : BuildHelperVO ) : Void
	{
		var constructorVO 		: ConstructorVO = buildHelperVO.constructorVO;
		var clazz 				: Class<Dynamic>;
		var qualifiedClassName 	: String = "";
		
		var args = constructorVO.arguments;

		if ( args != null && args.length > 0 )
		{
			qualifiedClassName = "" + args[0];
		}

		try
		{
			clazz = Type.resolveClass( qualifiedClassName );
		}
		catch ( e : Dynamic )
		{
			clazz = null;
		}
		
		if ( clazz == null )
		{
			throw new IllegalArgumentException( "'" + qualifiedClassName + "' is not available" );
		}

		constructorVO.result = clazz;
	}
}