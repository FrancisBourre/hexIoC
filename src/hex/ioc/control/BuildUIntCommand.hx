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
	public function new()
	{
		super();
	}
	
	override public function execute( ?e : IEvent ) : Void
	{
		var constructorVO : ConstructorVO 	= this._buildHelperVO.constructorVO;

		var args 	: Array<Dynamic> 		= constructorVO.arguments;
		var number 	: UInt 					= 0;

		if ( args != null && args.length > 0 ) 
		{
			number = Std.parseInt( Std.string( args[0] ) );
		}
		else
		{
			throw new IllegalArgumentException( this + ".execute(" + number + ") failed." );
		}

		#if js
		if ( number != null && number >= 0 )
		#else
		if ( Math.isNaN( number ) )
		#end
		{
			constructorVO.result = number;
		}
		else
		{
			throw new IllegalArgumentException( this + ".execute(" + number + ") failed." );
		}
	}
}