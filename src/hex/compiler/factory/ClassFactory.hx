package hex.compiler.factory;

import haxe.macro.Context;
import haxe.macro.Expr;
import hex.ioc.vo.FactoryVO;
import hex.error.IllegalArgumentException;
import hex.ioc.vo.ConstructorVO;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ClassFactory
{
	function new()
	{

	}
	
	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var constructorVO 		: ConstructorVO = factoryVO.constructorVO;
		var e 					: Expr = null;
		var qualifiedClassName 	: String = "";
		
		var args = constructorVO.arguments;

		if ( args != null && args.length > 0 )
		{
			qualifiedClassName = "" + args[0];
		}

		try
		{
			var tp = MacroUtil.getPack( qualifiedClassName );
			e = macro { $p { tp }; };
		}
		catch ( e : Dynamic )
		{
			Context.error( "'" + qualifiedClassName + "' is not available", Context.currentPos() );
		}
		
		if ( !constructorVO.isProperty )
		{
			var idVar = constructorVO.ID;
			factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $e; } );
		}
		
		return e;
	}
	#end
}