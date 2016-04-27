package hex.ioc.control;

import hex.ioc.vo.FactoryVO;
import hex.error.IllegalArgumentException;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class ClassFactory
{
	public function new()
	{

	}
	
	static public function build( factoryVO : FactoryVO ) : Void
	{
		var constructorVO 		: ConstructorVO = factoryVO.constructorVO;
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