package hex.ioc.control;

import hex.ioc.vo.FactoryVO;
import hex.error.IllegalArgumentException;
import hex.ioc.vo.ConstructorVO;
import hex.log.Logger;

/**
 * ...
 * @author Francis Bourre
 */
class StringFactory
{
	function new()
	{

	}
	
	static public function build( factoryVO : FactoryVO ) : Void
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;
		trace( constructorVO );

		var value : String 	= null;
		var args 			= constructorVO.arguments;

		if ( args != null && args.length > 0 && args[ 0 ] != null )
		{
			value = Std.string( args[0] );
		}
		else
		{
			throw new IllegalArgumentException( "StringFactory.build(" + value + ") returns empty String." );
		}

		if ( value == null )
		{
			value = "";
			#if debug
			Logger.WARN( "StringFactory.build(" + value + ") returns empty String." );
			#end
		}

		constructorVO.result = value;
		
		#if macro
		if ( !constructorVO.isProperty )
		{
			var idVar = constructorVO.ID;
			factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $v { value }; } );
		}
		#end
	}
}