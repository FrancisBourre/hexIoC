package hex.compiler.parser.flow;

import hex.compiler.parser.xml.ClassImportHelper;
import hex.ioc.assembler.ApplicationAssembler;

#if macro
import haxe.macro.Expr;
import hex.compiler.assembler.CompileTimeApplicationAssembler;
import hex.compiler.parser.preprocess.MacroConditionalVariablesProcessor;
import hex.ioc.assembler.ConditionalVariablesChecker;
#end

/**
 * ...
 * @author Francis Bourre
 */
class FlowCompiler 
{
	#if macro
	static function _readFile( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr, ?applicationAssemblerExpr : Expr ) : ExprOf<ApplicationAssembler>
	{
		var conditionalVariablesMap 	= MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		
		//var positionTracker			= new PositionTracker();
		var reader						= new DSLReader( /*positionTracker*/ );
		var document 					= reader.read( fileName, preprocessingVariables, conditionalVariablesChecker );
		
		var assembler 					= new CompileTimeApplicationAssembler( applicationAssemblerExpr );
		var parser 						= new CompileTimeParser( new ParserCollection() );
		
		parser.setImportHelper( new ClassImportHelper() );
		//parser.setExceptionReporter( new XmlAssemblingExceptionReporter( positionTracker ) );
		parser.parse( assembler, document );
		
		return assembler.getMainExpression();
	}
	#end

	macro public static function compile( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr ) : ExprOf<ApplicationAssembler>
	{
		return _readFile( fileName, preprocessingVariables, conditionalVariables );
	}
	
}