package hex.compiler.factory;

import haxe.macro.Expr;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.util.ClassUtil;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class StaticVariableFactory
{
	function new()
	{

	}

	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;
		var e : Expr = null;
		
		var className = ClassUtil.getClassNameFromStaticReference( constructorVO.staticRef );
		var staticVarName = ClassUtil.getStaticVariableNameFromStaticReference( constructorVO.staticRef );

		var tp = MacroUtil.getPack( className );
		e = macro { $p { tp }.$staticVarName; };
		
		if ( !constructorVO.isProperty )
		{
			var idVar = constructorVO.argumentName != null ? constructorVO.argumentName : constructorVO.ID;
			factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $e; } );
		}
		
		return e;
	}
	#end
}