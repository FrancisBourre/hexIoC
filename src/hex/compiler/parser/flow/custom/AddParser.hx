package hex.compiler.parser.flow.custom;

#if macro
import haxe.macro.*;
import haxe.macro.Expr;
import hex.compiletime.flow.parser.ExpressionParser;
import hex.compiletime.flow.parser.FlowExpressionParser;
import hex.core.ContextTypeList;
import hex.vo.ConstructorVO;
#end

/**
 * ...
 * @author Francis Bourre
 */
class AddParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	static var logger = hex.log.LogManager.LogManager.getLoggerByClass( AddParser );
	
	macro public static function activate() : haxe.macro.Expr.ExprOf<Bool>
	{
		//Sets the parser
		FlowExpressionParser.parser.buildMethodParser.set( 'add', hex.compiletime.flow.parser.custom.AddParser.parse );
		
		//Sets the builder
		if ( !hex.compiler.core.CompileTimeSettings.factoryMap.exists( 'haxe.macro.Expr' ) )
			hex.compiler.core.CompileTimeSettings.factoryMap.set( 'haxe.macro.Expr', hex.compiletime.factory.CodeFactory.build );
		
		return macro true;
	}
	
	macro public static function desactivate() : haxe.macro.Expr.ExprOf<Bool>
	{
		FlowExpressionParser.parser.buildMethodParser.remove( 'add' );
		return macro true;
	}
	
	#if macro
	public static function parse( parser : ExpressionParser, constructorVO : ConstructorVO, params : Array<Expr>, expr : Expr ) : ConstructorVO
	{
		if ( constructorVO.arguments == null ) constructorVO.arguments = [];
		
		var f = function( e ) {switch( e.expr )
		{
			case EConst(CIdent(ident)):
				constructorVO.arguments.push( new ConstructorVO( constructorVO.ID, ContextTypeList.INSTANCE, null, null, null, null, ident ) );
				case _:
		}};
		
		var e = params.shift();
		f( e );

		for ( param in params )
		{
			f( param );
			e = { expr: EBinop(OpAdd, e, param), pos:param.pos };
		}

		constructorVO.type = 'haxe.macro.Expr';
		constructorVO.arguments.unshift( e );
		constructorVO.filePosition = expr.pos;
		return constructorVO;
	}
	#end
}