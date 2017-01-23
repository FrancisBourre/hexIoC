package hex.compiler.parser.flow;

import haxe.macro.Context;
import haxe.macro.Expr;
import hex.compiler.core.CompileTimeContextFactory;
import hex.core.IApplicationContext;
import hex.core.IBuilder;
import hex.factory.BuildRequest;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.CompileTimeApplicationContext;
import hex.ioc.core.ContextAttributeList;

using hex.util.MacroUtil;
using hex.compiler.parser.flow.ExpressionUtil;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractExprParser extends DSLParser<Expr>
{
	var _builder 						: IBuilder<BuildRequest>;
	var _applicationContextName 		: String;
	var _applicationContextClassName 	: String;
	
	function new() 
	{
		super();
	}
	
	@final
	override public function getApplicationContext() : IApplicationContext
	{
		return this._applicationAssembler.getApplicationContext( this._applicationContextName, CompileTimeApplicationContext );
	}
	
	@final
	override public function setContextData( data : Expr ) : Void
	{
		if ( data != null )
		{
			this._contextData = data;
			this._findApplicationContextName( data );
			this._findApplicationContextClassName( data );
			
			this._builder = this._applicationAssembler.getFactory( CompileTimeContextFactory, this._applicationContextName, CompileTimeApplicationContext );
		}
		else
		{
			Context.error( "Context data is null.", Context.currentPos() );
		}
	}
	
	function _findApplicationContextName( data : Expr ) : Void
	{
		this._applicationContextName = switch( data.expr )
		{
			case EMeta( entry, e ) if ( entry.name == "context" ):

				var name = null;
				
				var a = Lambda.filter( entry.params, function ( p ) 
					{ 
						return switch( p.expr ) 
						{
							case EBinop( OpAssign, _.expr => EConst(CIdent('name')), e2 ) : true;
							case _: false;
						}
					} );

				if ( a.length == 1 )
				{
					name = switch( a.first().expr )
					{
						case EBinop( OpAssign, e1, _.expr => EConst(CString(id)) ) :
							id;
							
						case _:
							null;
					}
				}

				name;
				
			case _ :
				null;
		}
	}
	
	function _findApplicationContextClassName( data : Expr ) : Void
	{
		this._applicationContextClassName = switch( data.expr )
		{
			case EMeta( entry, e ) if ( entry.name == "context" ):

				var name = null;
				
				var a = Lambda.filter( entry.params, function ( p ) 
					{ 
						return switch( p.expr ) 
						{
							case EBinop( OpAssign, _.expr => EConst(CIdent('type')), e2 ) : true;
							case _: false;
						}
					} );

				if ( a.length == 1 )
				{
					name = switch( a.first().expr )
					{
						case EBinop( OpAssign, e1, e2 ) :
							e2.expr.compressField();
							
						case _:
							null;
					}
				}

				name;
				
			case _ :
				null;
		}
	}
	
	function _getExpressions() : Array<Expr>
	{
		var e = this.getContextData();

		switch( e.expr )
		{
			case EMeta( entry, _.expr => EBlock( exprs ) ) if ( entry.name == "context" ):
				return exprs;
			case _:
		}
		
		return [];
	}
	
	function _throwMissingTypeException( type : String, e : Expr, attributeName : String ) : Void 
	{
		Context.error( "Type not found '" + type + "' ", this._exceptionReporter.getPosition( e, attributeName ) );
	}
	
	function _throwMissingApplicationContextClassException() : Void 
	{
		this._throwMissingTypeException( this._applicationContextClassName, this.getContextData(), ContextAttributeList.TYPE );
	}
}