package hex.compiler.parser.flow;

import haxe.macro.ExprTools;
import hex.compiletime.flow.parser.ContextImport;
import hex.core.ContextTypeList;
import hex.core.IApplicationAssembler;
import hex.vo.ConstructorVO;

#if macro
import haxe.macro.Expr;
import hex.compiletime.CompileTimeApplicationAssembler;
import hex.compiletime.CompileTimeParser;
import hex.compiletime.ICompileTimeApplicationAssembler;
import hex.compiletime.basic.CompileTimeApplicationContext;
import hex.compiletime.flow.parser.ExpressionParser;
import hex.compiler.core.StaticCompileTimeContextFactory;
import hex.compiletime.flow.AbstractExprParser;
import hex.compiletime.flow.DSLReader;
import hex.compiletime.flow.FlowAssemblingExceptionReporter;
import hex.compiletime.util.ClassImportHelper;
import hex.compiletime.util.ContextBuilder;
import hex.core.VariableExpression;
import hex.log.LogManager;
import hex.log.MacroLoggerContext;
import hex.parser.AbstractParserCollection;
import hex.preprocess.ConditionalVariablesChecker;
import hex.preprocess.flow.MacroConditionalVariablesProcessor;
import hex.util.MacroUtil;

using hex.util.LambdaUtil;
using tink.MacroApi;
#end

/**
 * ...
 * @author Francis Bourre
 */
class StaticFlowCompiler 
{
	#if macro
	public static function _readFile(	fileName 				: String,
										?applicationContextName 		: String,
										?preprocessingVariables 		: Expr,
										?conditionalVariables 			: Expr,
										?applicationAssemblerExpression : Expr ) : Expr
	{
		LogManager.context 				= new MacroLoggerContext();
		
		var conditionalVariablesMap 	= MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		
		var conditionalVariablesMap 	= MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		
		var reader						= new DSLReader();
		var document 					= reader.read( fileName, preprocessingVariables, conditionalVariablesChecker );
	
		var assembler 					= new CompileTimeApplicationAssembler();
		var assemblerExpression			= { name: '', expression: applicationAssemblerExpression };
		var parser 						= new CompileTimeParser( new StaticParserCollection( assemblerExpression, fileName, reader.getRuntimeParam() ) );
		
		parser.setImportHelper( new ClassImportHelper() );
		parser.setExceptionReporter( new FlowAssemblingExceptionReporter() );
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
		return StaticFlowCompiler._readFile( fileName, applicationContextName, preprocessingVariables, conditionalVariables, assemblerExpr );
	}
	
	macro public static function extend<T>( assemblerExpr 			: Expr, 
											context 				: ExprOf<T>, 
											fileName 				: String, 
											?preprocessingVariables : Expr, 
											?conditionalVariables 	: Expr ) : ExprOf<T>
	{
		var contextName = StaticFlowCompiler._getContextName( context );
		return StaticFlowCompiler._readFile( fileName, contextName, preprocessingVariables, conditionalVariables, assemblerExpr );
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
class StaticParserCollection extends AbstractParserCollection<AbstractExprParser<hex.factory.BuildRequest>>
{
	var _runtimeParam 			: hex.preprocess.RuntimeParam;
	var _assemblerExpression 	: VariableExpression;
	var _fileName 				: String;
	
	public function new( assemblerExpression : VariableExpression, fileName : String, runtimeParam : hex.preprocess.RuntimeParam ) 
	{
		this._runtimeParam			= runtimeParam;
		this._assemblerExpression 	= assemblerExpression;
		this._fileName 				= fileName;

		super();
	}
	
	override function _buildParserList() : Void
	{
		this._parserCollection.push( new StaticContextParser( this._assemblerExpression ) );
		this._parserCollection.push( new RuntimeParameterParser( this._runtimeParam ) );
		this._parserCollection.push( new ImportContextParser( hex.compiletime.flow.parser.FlowExpressionParser.parser ) );
		this._parserCollection.push( new hex.compiler.parser.flow.ObjectParser( hex.compiletime.flow.parser.FlowExpressionParser.parser, this._runtimeParam ) );
		this._parserCollection.push( new StaticLauncher( this._assemblerExpression, this._fileName, this._runtimeParam ) );
	}
}

class ImportContextParser extends AbstractExprParser<hex.factory.BuildRequest>
{
	var _parser : ExpressionParser;
	
	public function new( parser : ExpressionParser ) 
	{
		super();
		this._parser 			= parser;
	}
	
	override public function parse() : Void 
	{
		this.transformContextData
		( 
			function( exprs :Array<Expr> ) 
			{
				var transformation = exprs.transformAndPartition( _transform );
				transformation.is.map( _parseImport );
				return transformation.isNot;
			}
		);
	}
	
	private function _transform( e : Expr ) : Transformation<Expr, ContextImport>
	{
		return switch ( e )
		{
			case macro $i{ident} = new Context( $a{params} ):
				Transformed( {
								id:ident, 
								fileName: 	switch( params[ 0 ].expr )
											{
												case EConst(CString(s)): s; 
												case _: ''; 
											}, 
								arg: params.length>1 ? this._parser.parseArgument( this._parser, ident, params[ 1 ] ): null,
								pos:e.pos 
							});
			
			case _: Original( e );
		}
	}
	
	function _parseImport( i : ContextImport )
	{
		var className = this._applicationContextName + '_' + i.id;
		var e = this._getCompiler( i.fileName )( i.fileName, className, null, null, macro this._applicationAssembler  );
		ContextBuilder.forceGeneration( className );
		
		var args = [ { className: 'hex.context.' + className/*this._getClassName( e )*/, expr: e, arg: i.arg } ];
		var vo = new ConstructorVO( i.id, ContextTypeList.CONTEXT, args );
		vo.filePosition = i.pos;
		this._builder.build( OBJECT( vo ) );
	}
	
	function _getClassName( expr : Expr ) : String
	{
		var className = '';
		
		function findClassName( e )
			switch( e.expr )
			{
				case ENew( t, params ): className = /*'I' +*/ t.pack.join('.') + '.' + t.name;
				case _: 				ExprTools.iter( e, findClassName );
			}
		
		ExprTools.iter( expr, findClassName );
		return className;
	}
	
	function _getCompiler( url : String )
	{
		//TODO remove hardcoded compilers assigned to extensions
		switch( url.split('.').pop() )
		{
			case 'xml':
				return hex.compiler.parser.xml.StaticXmlCompiler._readFile;
				
			case 'flow':
				return StaticFlowCompiler._readFile;
				
			case ext:
				trace( ext );
				
		}
		
		return null;
	}
}

class RuntimeParameterParser extends AbstractExprParser<hex.factory.BuildRequest>
{
	var _runtimeParam : hex.preprocess.RuntimeParam;
	
	public function new( runtimeParam : hex.preprocess.RuntimeParam ) 
	{
		super();
		this._runtimeParam 		= runtimeParam;
	}
	
	override public function parse() : Void
	{
		hex.preprocess.RuntimeParametersPreprocessor.getTypes( this._runtimeParam ).map(
			function ( param )
			{
				var vo = new hex.vo.PreProcessVO( param.name, [param.type] );
				vo.filePosition = param.pos;
				this._builder.build( PREPROCESS( vo ) );
			}
		);
	}
}

class StaticContextParser extends AbstractExprParser<hex.factory.BuildRequest>
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

class StaticLauncher extends AbstractExprParser<hex.factory.BuildRequest>
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