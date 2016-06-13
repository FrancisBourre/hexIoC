package hex.compiler.factory;

import haxe.macro.Context;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;

/**
 * ...
 * @author Francis Bourre
 */
class StringFactory
{
	function new()
	{

	}
	
	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;

		var value : String 	= null;
		var args 			= constructorVO.arguments;

		if ( args != null && args.length > 0 && args[ 0 ] != null )
		{
			value = Std.string( args[0] );
		}
		else
		{
			factoryVO.constructorVO.exceptionReporter.throwValueException( "String instance cannot returns empty String.", constructorVO );
		}

		if ( value == null )
		{
			value = "";
			#if debug
			Context.warning( "String instance cannot returns empty String.", Context.currentPos() );
			#end
		}

		constructorVO.result = value;
		
		if ( !constructorVO.isProperty )
		{
			var idVar = constructorVO.ID;
			factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $v { value }; } );
		}
		
		return macro { $v { value } };
	}
	#end
}