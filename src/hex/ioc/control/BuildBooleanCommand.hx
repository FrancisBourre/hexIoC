package hex.ioc.control;

import hex.control.Request;
import hex.error.IllegalArgumentException;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildBooleanCommand extends AbstractBuildCommand
{
	public function new()
	{
		super();
	}
	
	override public function execute( ?request : Request ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;

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