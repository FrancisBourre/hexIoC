package hex.compiler.parser.flow;

import hex.compiletime.flow.FlowAssemblingExceptionReporter;
import hex.compiletime.util.ClassImportHelper;
import hex.core.IApplicationAssembler;

#if macro
import haxe.macro.Expr;
import hex.compiletime.CompileTimeApplicationAssembler;
#end

/**
 * ...
 * @author Francis Bourre
 */
class FlowCompiler 
{
	#if macro
	static function _readFile( fileName : String, ?preprocessingVariables : Expr, ?applicationAssemblerExpr : Expr ) : ExprOf<IApplicationAssembler>
	{
		var reader						= new DSLReader();
		var document 					= reader.read( fileName, preprocessingVariables );
		
		var assembler 					= new CompileTimeApplicationAssembler( applicationAssemblerExpr );
		var parser 						= new CompileTimeParser( new ParserCollection() );
		
		parser.setImportHelper( new ClassImportHelper() );
		parser.setExceptionReporter( new FlowAssemblingExceptionReporter() );
		parser.parse( assembler, document );
		
		return assembler.getMainExpression();
	}
	#end

	macro public static function compile( fileName : String, ?preprocessingVariables : Expr ) : ExprOf<IApplicationAssembler>
	{
		return FlowCompiler._readFile( fileName, preprocessingVariables );
	}
	
	macro public static function compileWithAssembler( assemblerExpr : Expr, fileName : String, ?preprocessingVariables : Expr ) : ExprOf<IApplicationAssembler>
	{
		return FlowCompiler._readFile( fileName, preprocessingVariables, assemblerExpr );
	}
}