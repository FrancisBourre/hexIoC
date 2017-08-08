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
import hex.preprocess.MacroConditionalVariablesProcessor;
import hex.util.MacroUtil;

using tink.MacroApi;
#end

/**
 * ...
 * @author Francis Bourre
 */
class StaticXmlCompiler 
{
	#if macro
	public static function _readFile(	fileName 						: String,
										?applicationContextName 		: String,
										?preprocessingVariables 		: Expr,
										?conditionalVariables 			: Expr,
										?applicationAssemblerExpression : Expr ) : Expr
	{
		LogManager.context 				= new MacroLoggerContext();
		
		var conditionalVariablesMap 	= MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		
		var reader						= new DSLReader();
		var document 					= reader.read( fileName, preprocessingVariables, conditionalVariablesChecker );
	
		var assembler 					= new CompileTimeApplicationAssembler();
		var assemblerExpression			= { name: '', expression: applicationAssemblerExpression };
		var parser 						= new CompileTimeParser( new StaticParserCollection( assemblerExpression, fileName ) );
		
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
		return StaticXmlCompiler._readFile( fileName, applicationContextName, preprocessingVariables, conditionalVariables, assemblerExpr );
	}
	
	macro public static function extend<T>( assemblerExpr 			: Expr, 
											context 				: ExprOf<T>, 
											fileName 				: String, 
											?preprocessingVariables : Expr, 
											?conditionalVariables 	: Expr ) : ExprOf<T>
	{
		var contextName = StaticXmlCompiler._getContextName( context );
		return StaticXmlCompiler._readFile( fileName, contextName, preprocessingVariables, conditionalVariables, assemblerExpr );
	}
	
	#if macro
	static public function _getContextName( context )
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
	var _runtimeParam 			: hex.preprocess.RuntimeParam;
	var _assemblerExpression 	: VariableExpression;
	var _fileName 				: String;
	
	public function new( assemblerExpression : VariableExpression, fileName : String ) 
	{
		//Null pattern
		this._runtimeParam			= { type: null };
		this._assemblerExpression 	= assemblerExpression;
		this._fileName 				= fileName;
		
		super();
	}
	
	override function _buildParserList() : Void
	{
		this._parserCollection.push( new RuntimeParamsParser( this._runtimeParam ) );
		this._parserCollection.push( new StaticContextParser( this._assemblerExpression ) );
		this._parserCollection.push( new hex.compiler.parser.xml.StateParser() );
		this._parserCollection.push( new hex.compiler.parser.xml.ObjectParser() );
		this._parserCollection.push( new StaticLauncher( this._assemblerExpression, this._fileName, this._runtimeParam ) );
	}
}

class RuntimeParamsParser extends hex.compiletime.xml.AbstractXmlParser<hex.factory.BuildRequest>
{
	var _runtimeParam : hex.preprocess.RuntimeParam;
	
	public function new( runtimeParam : hex.preprocess.RuntimeParam )
	{
		this._runtimeParam = runtimeParam;
		
		super();
	}
	
	override public function parse() : Void
	{
		var iterator = this._contextData.firstElement().elementsNamed( hex.compiletime.xml.ContextNodeNameList.PARAMS );

		while ( iterator.hasNext() )
		{
			var node = iterator.next();
			this._parseNode( node );
			this._contextData.firstElement().removeChild( node );
		}
	}
	
	function _parseNode( xml : Xml ) : Void
	{
		var o = "var o:{";
		
		var elements = xml.elements();
		while ( elements.hasNext() )
		{
			var element = elements.next();
			
			var identifier = element.get( hex.compiletime.xml.ContextAttributeList.ID );
			if ( identifier == null )
			{
				this._exceptionReporter.report( "Parsing error with '" + xml.nodeName + 
												"' node, 'id' attribute not found.",
												this._positionTracker.getPosition( xml ) );
			}
			
			var type = element.get( hex.compiletime.xml.ContextAttributeList.TYPE );
			var vo = new hex.vo.PreProcessVO( identifier, [type] );
			vo.filePosition = haxe.macro.Context.currentPos();
			this._builder.build( PREPROCESS( vo ) );
			o += identifier + ":" + type + ",";
		}
		
		var e = haxe.macro.Context.parse( o.substr( 0, o.length - 1 ) + "}", haxe.macro.Context.currentPos() );
		var param = switch( e.expr )
		{
			case EVars(a):
					a[0].type;
			case _:
				null;
		}
		
		this._runtimeParam.type = param;
	}
}

class StaticContextParser extends hex.compiletime.xml.AbstractXmlParser<hex.factory.BuildRequest>
{
	var _assemblerVariable 	: VariableExpression;
	
	public function new( assemblerVariable : VariableExpression ) 
	{
		super();
		this._assemblerVariable = assemblerVariable;
	}
	
	override public function parse() : Void
	{
		//Register
		this._applicationContextClass.name = this._applicationContextClass.name != null ? this._applicationContextClass.name : Type.getClassName( hex.ioc.assembler.ApplicationContext );
		ContextBuilder.register( this._applicationAssembler.getFactory( this._factoryClass, this.getApplicationContext() ), this._applicationContextClass.name );
		
		//Create runtime applicationAssembler
		if ( this._assemblerVariable.expression == null )
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
	var _runtimeParam 		: hex.preprocess.RuntimeParam;
	
	public function new( assemblerVariable : VariableExpression, fileName : String, runtimeParam : hex.preprocess.RuntimeParam = null ) 
	{
		super();
		
		this._assemblerVariable = assemblerVariable;
		this._fileName 			= fileName;
		this._runtimeParam 		= runtimeParam;
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
		var file 	= ContextBuilder.getInstance( factory ).buildFileExecution( this._fileName, assembler.getMainExpression(), this._runtimeParam );
		
		var contextName = this._applicationContextName;
		var varType = builder.getType();
		
		var className = builder._iteration.definition.name;
		
		var classExpr;
		
		var applicationContextClassName = this._applicationContextClass.name == null ? 
			Type.getClassName( hex.ioc.assembler.ApplicationContext ): 
				this._applicationContextClass.name;
				
		var applicationContextClassPack = MacroUtil.getPack( applicationContextClassName );
		var applicationContextCT		= haxe.macro.TypeTools.toComplexType( haxe.macro.Context.getType( applicationContextClassName ) );
				
		classExpr = macro class $className { public function new( assembler )
		{
			this.locator 				= hex.compiletime.CodeLocator.get( $v { contextName }, assembler );
			this.applicationAssembler 	= assembler;
			this.applicationContext 	= this.locator.$contextName;
		}};

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
		
		var locatorArguments = if ( this._runtimeParam.type != null ) [ { name: 'param', type:_runtimeParam.type } ] else [];
		
		var locatorBody = this._runtimeParam.type != null ?
			macro hex.compiletime.CodeLocator.get( $v { contextName }, applicationAssembler ).$file(param) :
				macro hex.compiletime.CodeLocator.get( $v { contextName }, applicationAssembler ).$file();
				
		var className = classExpr.pack.join( '.' ) + '.' + classExpr.name;
		var cls = className.asTypePath();
		var cloneBody = macro @:mergeBlock 
		{
			return new $cls( assembler ); 
		};
		
		classExpr.fields.push(
		{
			name: 'execute',
			pos: haxe.macro.Context.currentPos(),
			kind: FFun( 
			{
				args: locatorArguments,
				ret: macro : Void,
				expr: locatorBody
			}),
			access: [ APublic ]
		});
		
		classExpr.fields.push(
		{
			name: 'clone',
			pos: haxe.macro.Context.currentPos(),
			kind: FFun( 
			{
				args: [{name:'assembler', type:macro:hex.core.IApplicationAssembler}],
				ret: className.asComplexType(),
				expr: cloneBody
			}),
			access: [ APublic ]
		});
		
		haxe.macro.Context.defineType( classExpr );
		var typePath = MacroUtil.getTypePath( className );
		assembler.setMainExpression( macro @:mergeBlock { new $typePath( $assemblerVarExpression ); }  );
	}
}
#end