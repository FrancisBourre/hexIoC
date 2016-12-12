package hex.compiler.parser.xml;

import hex.compiler.assembler.CompileTimeApplicationAssembler;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeLauncher extends CompileTimeXMLParser
{
	public function new() 
	{
		super();
	}
	
	override public function parse() : Void
	{
		var assembler : CompileTimeApplicationAssembler = cast this._applicationAssembler;
		
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
		assembler.addExpression( assembler.getAssemblerExpression() );
	}
}