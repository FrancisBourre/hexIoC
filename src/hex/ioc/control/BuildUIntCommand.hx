package hex.ioc.control;

import hex.ioc.vo.ConstructorVO;
import hex.error.IllegalArgumentException;
import hex.event.IEvent;
import hex.ioc.control.AbstractBuildCommand;

/**
 * ...
 * @author Francis Bourre
 */
class BuildUIntCommand extends AbstractBuildCommand
{
	override public function execute( ?e : IEvent ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;

		var args 	: Array<Dynamic> 	= constructorVO.arguments;
		var number 	: Float 	= Math.NaN;

		if ( args != null && args.length > 0 ) number = Std.parseInt( Std.string( args[0] ) );

		if ( !Math.isNaN( number ) && number <= Math.POSITIVE_INFINITY && number >= 0 )
		{
			constructorVO.result = number;
		}
		else
		{
			throw new IllegalArgumentException( this + ".execute(" + number + ") failed." );
		}
	}
}