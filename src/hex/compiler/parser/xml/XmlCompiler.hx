package hex.compiler.parser.xml;

import hex.ioc.assembler.ApplicationAssembler;

#if macro
import haxe.macro.Expr;
import hex.compiler.assembler.CompileTimeApplicationAssembler;
import hex.compiler.parser.preprocess.MacroConditionalVariablesProcessor;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.ConditionalVariablesChecker;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.parser.xml.XmlAssemblingExceptionReporter;
import hex.util.MacroUtil;
#end

using StringTools;

/**
 * ...
 * @author Francis Bourre
 */
class XmlCompiler
{
	#if macro
	static function getApplicationContext( document : Xml, exceptionReporter : XmlAssemblingExceptionReporter, assemblerExpr : Expr ) : ExprOf<AbstractApplicationContext>
	{
		var xml = document.firstElement();
		
		var applicationContextClass = null;
		var applicationContextClassName : String = xml.get( ContextAttributeList.TYPE );
		
		if ( applicationContextClassName != null )
		{
			try
			{
				applicationContextClass = MacroUtil.getPack( applicationContextClassName );
			}
			catch ( error : Dynamic )
			{
				exceptionReporter.throwMissingTypeException( applicationContextClassName, xml, ContextAttributeList.TYPE );
			}
		}
		
		var applicationContextName : String = XmlCompiler.getRootApplicationContextName( xml, exceptionReporter );
		
		var expr;
		if ( applicationContextClass != null )
		{
			expr = macro @:mergeBlock { var applicationContext = $assemblerExpr.getApplicationContext( $v { applicationContextName }, $p { applicationContextClass } ); };
		}
		else
		{
			expr = macro @:mergeBlock { var applicationContext = $assemblerExpr.getApplicationContext( $v { applicationContextName } ); };
		}

		return expr;
	}
	
	static function getRootApplicationContextName( xml : Xml, exceptionReporter : XmlAssemblingExceptionReporter ) : String
	{
		var applicationContextName : String = xml.get( "name" );
		if ( applicationContextName == null )
		{
			exceptionReporter.throwMissingApplicationContextNameException( xml );
			return null;
		}
		else
		{
			return applicationContextName;
		}
	}
	
	static function _readXmlFile( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr, ?applicationAssemblerExpr : Expr ) : ExprOf<ApplicationAssembler>
	{
		var conditionalVariablesMap 	= MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		
		var positionTracker				= new PositionTracker() ;
		var parser						= new XmlDSLParser( positionTracker );
		var document 					= parser.parse( fileName, preprocessingVariables, conditionalVariablesChecker );
		var exceptionReporter 			= new XmlAssemblingExceptionReporter( positionTracker );
		var importHelper 				= new ClassImportHelper();
		
		//
		var assembler 					= new CompileTimeApplicationAssembler();
		var applicationContext 			= assembler.getApplicationContext( XmlCompiler.getRootApplicationContextName( document.firstElement(), exceptionReporter ) );
		
		//State parsing
		var stateParser = new CompileTimeStateParser( assembler, importHelper );
		var iterator = document.firstElement().elementsNamed( "state" );
		while ( iterator.hasNext() )
		{
			var node = iterator.next();
			stateParser.parseNode( applicationContext, node, exceptionReporter );
			document.firstElement().removeChild( node );
		}
		
		//DSL parsing
		var objectParser = new CompileTimeObjectParser( assembler, importHelper );
		iterator = document.firstElement().elements();
		while ( iterator.hasNext() )
		{
			objectParser.parseNode( applicationContext, iterator.next(), exceptionReporter );
		}

		//Create runtime applicationAssembler
		var applicationAssemblerTypePath = MacroUtil.getTypePath( Type.getClassName( ApplicationAssembler ) );
		
		var applicationAssemblerVarName : String = "";
		
		if ( applicationAssemblerExpr == null )
		{
			applicationAssemblerVarName = 'applicationAssembler';
			assembler.addExpression( macro @:mergeBlock { var $applicationAssemblerVarName = new $applicationAssemblerTypePath(); } );
			applicationAssemblerExpr = macro $i { applicationAssemblerVarName };
		}
		
		//Create runtime applicationContext
		assembler.addExpression( getApplicationContext( document, exceptionReporter, applicationAssemblerExpr ) );
		
		//Dispatch CONTEXT_PARSED message
		var messageType = MacroUtil.getStaticVariable( "hex.ioc.assembler.ApplicationAssemblerMessage.CONTEXT_PARSED" );
		assembler.addExpression( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
		
		//Create applicationcontext injector
		assembler.addExpression( macro @:mergeBlock { var __applicationContextInjector = applicationContext.getInjector(); } );
			
		//Create runtime coreFactory
		assembler.addExpression( macro @:mergeBlock { var coreFactory = applicationContext.getCoreFactory(); } );
		
		//Create runtime AnnotationProvider
		assembler.addExpression( macro @:mergeBlock { var __annotationProvider = applicationContext.getCoreFactory().getAnnotationProvider(); } );

		//build
		assembler.buildEverything();
		
		//return program
		assembler.addExpression( applicationAssemblerExpr );
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
