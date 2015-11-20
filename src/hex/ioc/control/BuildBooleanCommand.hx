package hex.ioc.control;
import hex.error.IllegalArgumentException;
import hex.event.IEvent;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildBooleanCommand extends AbstractBuildCommand
{
	public function new() 
	{
		
	}
	
	override public function execute( ?e : IEvent ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;

		var value : String = "";
		var args = constructorVO.arguments;

		if ( args != null && args.length > 0 ) 
		{
			value = Std.string( args[0] );
		}

		if ( value.length < 0 || Std.parseInt( value ) == 0 )
		{
			throw new IllegalArgumentException( this + ".build(" + value + ") failed." );
			//constructorVO.result = false;
		}
		else
		{
			constructorVO.result = ( value == "true" || !Math.isNaN( Std.parseInt( value ) ) && Std.parseInt( value ) != 0 ) ? true : false;
		}
	}
}