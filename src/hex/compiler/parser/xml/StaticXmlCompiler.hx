package hex.compiler.parser.xml;


import hex.core.IApplicationAssembler;

#if macro
import haxe.macro.Expr;
import hex.compiletime.CompileTimeApplicationAssembler;
import hex.compiletime.CompileTimeParser;
import hex.compiletime.ICompileTimeApplicationAssembler;
import hex.compiletime.basic.CompileTimeApplicationContext;
import hex.compiler.core.StaticCompileTimeContextFactory;
import hex.compiletime.flow.AbstractExprParser;
import hex.compiletime.xml.DSLReader;
import hex.compiletime.xml.ExceptionReporter;
import hex.compiletime.util.ClassImportHelper;
import hex.compiletime.util.ContextBuilder;
import hex.core.VariableExpression;
import hex.log.LogManager;
import hex.log.MacroLoggerContext;
import hex.parser.AbstractParserCollection;
import hex.preprocess.ConditionalVariablesChecker;
import hex.preprocess.flow.MacroConditionalVariablesProcessor;
import hex.util.MacroUtil;
#end

/**
 * ...
 * @author Francis Bourre
 */
class StaticXmlCompiler 
{
	#if macro
	static function _readFile(	fileName 						: String, 
								?applicationContextName 		: String,
								?preprocessingVariables 		: Expr, 
								?conditionalVariables 			: Expr, 
								?applicationAssemblerExpression : Expr,
								isExtending 					: Bool = false ) : Expr
	{
		LogManager.context 				= new MacroLoggerContext();
		
		var conditionalVariablesMap 	= MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		
		var reader						= new DSLReader();
		var document 					= reader.read( fileName, preprocessingVariables, conditionalVariablesChecker );
	
		var assembler 					= new CompileTimeApplicationAssembler();
		var assemblerExpression			= { name: '', expression: applicationAssemblerExpression };
		var parser 						= new CompileTimeParser( new StaticParserCollection( assemblerExpression, fileName, isExtending ) );
		
		parser.setImportHelper( new ClassImportHelper() );
		parser.setExceptionReporter( new ExceptionReporter( reader.positionTracker ) );
		parser.parse( assembler, document, StaticCompileTimeContextFactory, CompileTimeApplicationContext, applicationContextName );
		
		return assembler.getMainExpression();
	}
	#end

	macro public static function compile( 	assemblerExpr 			: Expr, 
											fileName 				: String,
											?applicationContextName : String,
											?preprocessingVariables : Expr, 
											?conditionalVariables 	: Expr ) : Expr
	{
		return StaticXmlCompiler._readFile( fileName, applicationContextName, preprocessingVariables, conditionalVariables, assemblerExpr, false );
	}
	
	macro public static function extend<T>( context 				: ExprOf<T>, 
											fileName 				: String, 
											?preprocessingVariables : Expr, 
											?conditionalVariables 	: Expr ) : ExprOf<T>
	{
		var contextName = StaticXmlCompiler._getContextName( context );
		return StaticXmlCompiler._readFile( fileName, contextName, preprocessingVariables, conditionalVariables, null, true );
	}
	
	#if macro
	static function _getContextName( context )
	{
		var ident = switch( context.expr ) 
		{ 
			case EConst( CIdent( s ) ): "" + s; 
			case _: ""; 
		}
		var localVar = haxe.macro.Context.getLocalVars().get( ident );

		var interfaceName = switch ( localVar )
		{
			case TInst( a, b ):
				Std.string( a ).split( '.' ).pop();
				
			case _:
				null;
		}
		
		return ContextBuilder.getApplicationContextName( interfaceName );
	}
	#end
}

#if macro
class StaticParserCollection extends hex.parser.AbstractParserCollection<hex.compiletime.xml.AbstractXmlParser<hex.factory.BuildRequest>>
{
	var _assemblerExpression 	: VariableExpression;
	var _fileName 				: String;
	var _isExtending 			: Bool;
	
	public function new( assemblerExpression : VariableExpression, fileName : String, isExtending : Bool = false ) 
	{
		this._assemblerExpression 	= assemblerExpression;
		this._fileName 				= fileName;
		this._isExtending 			= isExtending;
		
		super();
	}
	
	override function _buildParserList() : Void
	{
		this._parserCollection.push( new StaticContextParser( this._assemblerExpression, this._isExtending ) );
		this._parserCollection.push( new hex.compiler.parser.xml.StateParser() );
		this._parserCollection.push( new hex.compiler.parser.xml.ObjectParser() );
		this._parserCollection.push( new StaticLauncher( this._assemblerExpression, this._fileName, this._isExtending ) );
	}
}

class StaticContextParser extends hex.compiletime.xml.AbstractXmlParser<hex.factory.BuildRequest>
{
	var _assemblerVariable 	: VariableExpression;
	var _isExtending 		: Bool;
	
	public function new( assemblerVariable : VariableExpression, isExtending : Bool = false ) 
	{
		super();
		this._assemblerVariable = assemblerVariable;
		this._isExtending 		= isExtending;
	}
	
	override public function parse() : Void
	{
		//Register
		this._applicationContextClass.name = this._applicationContextClass.name != null ? this._applicationContextClass.name : Type.getClassName( hex.ioc.assembler.ApplicationContext );
		ContextBuilder.register( this._applicationAssembler.getFactory( this._factoryClass, this.getApplicationContext() ), this._applicationContextClass.name );
		
		//Create runtime applicationAssembler
		if ( this._assemblerVariable.expression == null && !this._isExtending )
		{
			var applicationAssemblerTypePath = MacroUtil.getTypePath( "hex.runtime.ApplicationAssembler" );
			this._assemblerVariable.expression = macro new $applicationAssemblerTypePath();
		}
		
		//Create runtime applicationContext
		var applicationContextClass = null;
		try
		{
			applicationContextClass = MacroUtil.getPack( this._applicationContextClass.name );
		}
		catch ( error : Dynamic )
		{
			this._exceptionReporter.report( "Type not found '" + this._applicationContextClass.name + "' ", this._applicationContextClass.pos );
		}

		
		//Add expression
		var expr = macro @:mergeBlock { var applicationContext = this._applicationAssembler.getApplicationContext( $v { this._applicationContextName }, $p { applicationContextClass } ); };
		( cast this._applicationAssembler ).addExpression( expr );
	}
}

class StaticLauncher extends hex.compiletime.xml.AbstractXmlParser<hex.factory.BuildRequest>
{
	var _assemblerVariable 	: VariableExpression;
	var _fileName 			: String;
	var _isExtending 		: Bool;
	
	public function new( assemblerVariable : VariableExpression, fileName : String, isExtending : Bool = false  ) 
	{
		super();
		
		this._assemblerVariable = assemblerVariable;
		this._fileName 			= fileName;
		this._isExtending 		= isExtending;
	}
	
	override public function parse() : Void
	{
		var assembler : ICompileTimeApplicationAssembler = cast this._applicationAssembler;
		
		//Dispatch CONTEXT_PARSED message
		var messageType = MacroUtil.getStaticVariable( "hex.core.ApplicationAssemblerMessage.CONTEXT_PARSED" );
		assembler.addExpression( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );

		//Create applicationcontext injector
		assembler.addExpression( macro @:mergeBlock { var __applicationContextInjector = applicationContext.getInjector(); } );

		//Create runtime coreFactory
		assembler.addExpression( macro @:mergeBlock { var coreFactory = applicationContext.getCoreFactory(); } );
		
		var pack = MacroUtil.getPack( Type.getClassName( hex.metadata.IAnnotationProvider ) );
		assembler.addExpression( macro @:mergeBlock { var __annotationProvider = __applicationContextInjector.getInstance( $p { pack } ); } );

		//build
		assembler.buildEverything();

		//
		var assemblerVarExpression = this._assemblerVariable.expression;
		var factory = assembler.getFactory( this._factoryClass, this.getApplicationContext() );
		var builder = ContextBuilder.getInstance( factory );
		var file 	= ContextBuilder.getInstance( factory ).buildFileExecution( this._fileName, assembler.getMainExpression() );
		
		var contextName = this._applicationContextName;
		var varType = builder.getType();
		
		var className = builder._iteration.definition.name;
		
		var classExpr;
		
		var applicationContextClassName = this._applicationContextClass.name == null ? 
			Type.getClassName( hex.ioc.assembler.ApplicationContext ): 
				this._applicationContextClass.name;
				
		var applicationContextClassPack = MacroUtil.getPack( applicationContextClassName );
		var applicationContextCT		= haxe.macro.TypeTools.toComplexType( haxe.macro.Context.getType( applicationContextClassName ) );
				
		if ( this._isExtending )
		{
			classExpr = macro class $className { public function new()
			{
				this.locator 				= hex.compiletime.CodeLocator.get( $v { contextName } );
				this.applicationAssembler 	= ( cast locator )._applicationAssembler;
				this.applicationContext 	= this.locator.$contextName;
			}};
		}
		else
		{
			classExpr = macro class $className { public function new( assembler )
			{
				this.locator 				= hex.compiletime.CodeLocator.get( $v { contextName }, assembler );
				this.applicationAssembler 	= assembler;
				this.applicationContext 	= this.locator.$contextName;
			}};
		}

		classExpr.pack = [ "hex", "context" ];
		
		classExpr.fields.push(
		{
			name: 'locator',
			pos: haxe.macro.Context.currentPos(),
			kind: FVar( varType ),
			access: [ APublic ]
		});
		
		classExpr.fields.push(
		{
			name: 'applicationAssembler',
			pos: haxe.macro.Context.currentPos(),
			kind: FVar( macro:hex.core.IApplicationAssembler ),
			access: [ APublic ]
		});
		
		classExpr.fields.push(
		{
			name: 'applicationContext',
			pos: haxe.macro.Context.currentPos(),
			kind: FVar( applicationContextCT ),
			access: [ APublic ]
		});
		
		classExpr.fields.push(
		{
			name: 'execute',
			pos: haxe.macro.Context.currentPos(),
			kind: FFun( 
			{
				args: [],
				ret: macro : Void,
				expr: macro hex.compiletime.CodeLocator.get( $v { contextName } ).$file()
			}),
			access: [ APublic ]
		});
		
		haxe.macro.Context.defineType( classExpr );
		var typePath = MacroUtil.getTypePath( classExpr.pack.join( '.' ) + '.' + classExpr.name );

		if ( this._isExtending )
		{
			assembler.setMainExpression( macro @:mergeBlock { new $typePath(); }  );
		}
		else
		{
			assembler.setMainExpression( macro @:mergeBlock { new $typePath( $assemblerVarExpression ); }  );
		}
	}
}
#end