package hex.ioc.control;

import hex.error.IllegalArgumentException;
import hex.event.IEvent;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildFloatCommand extends AbstractBuildCommand
{
	public function new() 
	{
		
	}
	
	override public function execute( ?e : IEvent ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;

		var args : Array 	= constructorVO.arguments;
		var number : Number = Math.NaN;

		if ( args != null && args.length > 0 ) number = Std.parseFloat( Std.string( args[0] ) );

		if ( !Math.isNaN( number ) && number <= Math.POSITIVE_INFINITY && number >= Math.NEGATIVE_INFINITY )
		{
			constructorVO.result = number;
		}
		else
		{
			throw new IllegalArgumentException( this + ".execute(" + number + ") failed." );
		}
	}
}