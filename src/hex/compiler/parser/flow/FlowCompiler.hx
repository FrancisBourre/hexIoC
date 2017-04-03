package hex.compiler.parser.flow;

import hex.core.IApplicationAssembler;

#if macro
import haxe.macro.Expr;
import hex.compiler.core.CompileTimeContextFactory;
import hex.compiletime.CompileTimeApplicationAssembler;
import hex.compiletime.CompileTimeParser;
import hex.compiletime.flow.DSLReader;
import hex.compiletime.flow.FlowAssemblingExceptionReporter;
import hex.compiletime.util.ClassImportHelper;
import hex.compiletime.basic.CompileTimeApplicationContext;
import hex.log.MacroLoggerContext;
import hex.log.LogManager;
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
		LogManager.context = new MacroLoggerContext();
		
		var reader						= new DSLReader();
		var document 					= reader.read( fileName, preprocessingVariables );
		
		var assembler 					= new CompileTimeApplicationAssembler( applicationAssemblerExpr );
		var parser 						= new CompileTimeParser( new ParserCollection() );
		
		parser.setImportHelper( new ClassImportHelper() );
		parser.setExceptionReporter( new FlowAssemblingExceptionReporter() );
		parser.parse( assembler, document, CompileTimeContextFactory, CompileTimeApplicationContext );
		
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