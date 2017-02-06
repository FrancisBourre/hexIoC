package hex.compiler.parser.xml;

import hex.compiler.core.CompileTimeContextFactory;
import hex.compiletime.CompileTimeParser;
import hex.compiletime.util.ClassImportHelper;
import hex.compiletime.xml.DSLReader;
import hex.core.IApplicationAssembler;
import hex.ioc.assembler.CompileTimeApplicationContext;

#if macro
import haxe.macro.Expr;
import hex.compiletime.CompileTimeApplicationAssembler;
import hex.preprocess.MacroConditionalVariablesProcessor;
import hex.ioc.assembler.ConditionalVariablesChecker;
import hex.compiletime.xml.ExceptionReporter;
#end

using StringTools;

/**
 * ...
 * @author Francis Bourre
 */
class XmlCompiler
{
	#if macro
	static function _readXmlFile( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr, ?applicationAssemblerExpr : Expr ) : ExprOf<IApplicationAssembler>
	{
		var conditionalVariablesMap 	= MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		
		var dslReader					= new DSLReader();
		var document 					= dslReader.read( fileName, preprocessingVariables, conditionalVariablesChecker );
		
		var assembler 					= new CompileTimeApplicationAssembler( applicationAssemblerExpr );
		var parser 						= new CompileTimeParser( new ParserCollection() );
		
		parser.setImportHelper( new ClassImportHelper() );
		parser.setExceptionReporter( new ExceptionReporter( dslReader.positionTracker ) );
		parser.parse( assembler, document, CompileTimeContextFactory, CompileTimeApplicationContext );

		return assembler.getMainExpression();
	}
	#end
	
	macro public static function readXmlFile( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr ) : ExprOf<IApplicationAssembler>
	{
		return _readXmlFile( fileName, preprocessingVariables, conditionalVariables );
	}
	
	macro public static function readXmlFileWithAssembler( assemblerExpr : Expr, fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr ) : ExprOf<IApplicationAssembler>
	{
		return _readXmlFile( fileName, preprocessingVariables, conditionalVariables, assemblerExpr );
	}
}
