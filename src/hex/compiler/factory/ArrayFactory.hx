package hex.compiler.factory;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;

/**
 * ...
 * @author Francis Bourre
 */
class ArrayFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }
	
	#if macro
	static public function build( factoryVO : FactoryVO ) : Expr
	{
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		var args 				= ArgumentFactory.build( factoryVO );

		if ( constructorVO.shouldAssign )
		{
			var exp 	= Context.parseInlineString( "new " + constructorVO.type + "()", constructorVO.filePosition );
			var varType = TypeTools.toComplexType( Context.typeof( exp ) );
			var result 	= macro @:pos( constructorVO.filePosition ) var $idVar : $varType = $a{ args };

			return result;
		}
		else
		{
			return macro @:pos( constructorVO.filePosition ) $a{ args };
		}
	}
	#end
}