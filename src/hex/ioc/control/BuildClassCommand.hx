package hex.ioc.control;

import hex.error.IllegalArgumentException;
import hex.event.IEvent;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildClassCommand extends AbstractBuildCommand
{
	public function new()
	{
		super();
	}
	
	override public function execute( ?e : IEvent ) : Void
	{
		var constructorVO 		: ConstructorVO = this._buildHelperVO.constructorVO;
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