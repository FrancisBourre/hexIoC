package hex.ioc.control;

import hex.ioc.vo.FactoryVO;
import hex.error.IllegalArgumentException;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BoolFactory
{
	function new()
	{

	}
	
	static public function build( factoryVO : FactoryVO ) : Void
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;

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
			throw new IllegalArgumentException( "BoolFactory.build(" + value + ") failed." );
		}
		
		#if macro
		if ( !constructorVO.isProperty )
		{
			var idVar = constructorVO.ID;
			factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $v { constructorVO.result }; } );
		}
		#end
	}
}