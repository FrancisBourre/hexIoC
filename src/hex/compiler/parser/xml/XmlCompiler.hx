package hex.compiler.parser.xml;

import hex.ioc.assembler.ApplicationAssembler;

#if macro
import haxe.macro.Expr;
import hex.compiler.assembler.CompileTimeApplicationAssembler;
import hex.compiler.parser.preprocess.MacroConditionalVariablesProcessor;
import hex.ioc.assembler.ConditionalVariablesChecker;
import hex.ioc.parser.xml.XmlAssemblingExceptionReporter;
#end

using StringTools;

/**
 * ...
 * @author Francis Bourre
 */
class XmlCompiler
{
	#if macro
	static function _readXmlFile( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr, ?applicationAssemblerExpr : Expr ) : ExprOf<ApplicationAssembler>
	{
		var conditionalVariablesMap 	= MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		var positionTracker				= new PositionTracker() ;
		
		var parser						= new XmlDSLParser( positionTracker );
		var document 					= parser.parse( fileName, preprocessingVariables, conditionalVariablesChecker );
		var exceptionReporter 			= new XmlAssemblingExceptionReporter( positionTracker );
		var importHelper 				= new ClassImportHelper();
		
		var assembler 					= new CompileTimeApplicationAssembler( applicationAssemblerExpr );
		
		var parser 						= new CompileTimeParser( new CompileTimeParserCollection() );
		parser.setImportHelper( importHelper );
		parser.setExceptionReporter( exceptionReporter );
		parser.parse( assembler, document );

		return assembler.getMainExpression();
	}
	#end
	
	macro public static function readXmlFile( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr ) : ExprOf<ApplicationAssembler>
	{
		return _readXmlFile( fileName, preprocessingVariables, conditionalVariables );
	}
	
	macro public static function readXmlFileWithAssembler( assemblerExpr : Expr, fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr ) : ExprOf<ApplicationAssembler>
	{
		return _readXmlFile( fileName, preprocessingVariables, conditionalVariables, assemblerExpr );
	}
}
