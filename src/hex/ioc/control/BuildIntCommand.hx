package hex.ioc.control;

import hex.control.Request;
import hex.error.IllegalArgumentException;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildIntCommand extends AbstractBuildCommand
{
	public function new()
	{
		super();
	}
	
	override public function execute( ?request : Request ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;
		var args 	: Array<Dynamic> 	= constructorVO.arguments;
		var number 	: Int = 0;

		if ( args != null && args.length > 0 ) 
		{
			number = Std.parseInt( Std.string( args[0] ) );
		}
		else
		{
			throw new IllegalArgumentException( this + ".execute(" + ( args != null && args.length > 0 ? args[0] : "" ) + ") failed." );
		}

		#if js
		if ( number == null )
		#else
		if ( "" + number != args[0] )
		#end
		{
			throw new IllegalArgumentException( this + ".execute(" + number + ") failed." );
		}
		else
		{
			constructorVO.result = number;
		}
	}
}