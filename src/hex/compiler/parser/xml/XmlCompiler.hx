package hex.compiler.parser.xml;

import hex.core.IApplicationAssembler;

#if macro
import haxe.macro.Expr;
import hex.compiler.core.CompileTimeContextFactory;
import hex.compiletime.CompileTimeApplicationAssembler;
import hex.compiletime.CompileTimeParser;
import hex.compiletime.util.ClassImportHelper;
import hex.compiletime.xml.DSLReader;
import hex.compiletime.xml.ExceptionReporter;
import hex.compiletime.basic.CompileTimeApplicationContext;
import hex.preprocess.ConditionalVariablesChecker;
import hex.preprocess.MacroConditionalVariablesProcessor;
import hex.log.MacroLoggerContext;
import hex.log.LogManager;

using StringTools;
#end

/**
 * ...
 * @author Francis Bourre
 */
class XmlCompiler
{
	#if macro
	static function _readXmlFile( 	fileName : String, 
									?applicationContextName : String, 
									?preprocessingVariables : Expr, 
									?conditionalVariables : Expr, 
									?applicationAssemblerExpression : Expr ) : ExprOf<IApplicationAssembler>
	{
		LogManager.context = new MacroLoggerContext();
		
		var conditionalVariablesMap 	= MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		
		var dslReader					= new DSLReader();
		var document 					= dslReader.read( fileName, preprocessingVariables, conditionalVariablesChecker );
		
		var assembler 					= new CompileTimeApplicationAssembler();
		var assemblerExpression			= { name: '', expression: applicationAssemblerExpression };
		var parser 						= new CompileTimeParser( new ParserCollection( assemblerExpression ) );
		
		parser.setImportHelper( new ClassImportHelper() );
		parser.setExceptionReporter( new ExceptionReporter( dslReader.positionTracker ) );
		parser.parse( assembler, document, CompileTimeContextFactory, CompileTimeApplicationContext, applicationContextName );

		return assembler.getMainExpression();
	}
	#end
	
	macro public static function compile( 	fileName : String, 
											?applicationContextName : String, 
											?preprocessingVariables : Expr, 
											?conditionalVariables : Expr ) : ExprOf<IApplicationAssembler>
	{
		return XmlCompiler._readXmlFile( fileName, applicationContextName, preprocessingVariables, conditionalVariables  );
	}
	
	macro public static function compileWithAssembler( 	assemblerExpr : Expr, 
														fileName : String, 
														?applicationContextName : String, 
														?preprocessingVariables : Expr, 
														?conditionalVariables : Expr ) : ExprOf<IApplicationAssembler>
	{
		return XmlCompiler._readXmlFile( fileName, applicationContextName, preprocessingVariables, conditionalVariables, assemblerExpr );
	}
}
