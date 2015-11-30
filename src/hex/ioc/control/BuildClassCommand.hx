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
	private function new() 
	{
		
	}

	override public function execute( ?e : IEvent ) : Void
	{
		var constructorVO 		: ConstructorVO = this._buildHelperVO.constructorVO;

		var clazz 				: Class<Dynamic>;
		var msg 				: String;
		var qualifiedClassName 	: String = "";
		
		var args = constructorVO.arguments;

		if ( args != null && args.length > 0 )
		{
			if ( Std.is( args[ 0 ], Class ) )
			{
				constructorVO.result = args[0];
				return;

			} else
			{
				qualifiedClassName = Std.string( args[0] );
			}
		}

		try
		{
			clazz = Type.resolveClass( qualifiedClassName );

		} catch ( e : Dynamic )
		{
			msg = " '" + qualifiedClassName + "' is not available";
			throw new IllegalArgumentException( msg );
		}

		constructorVO.result = clazz;
	}
}