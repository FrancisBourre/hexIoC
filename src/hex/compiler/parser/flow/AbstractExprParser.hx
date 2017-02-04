package hex.compiler.parser.flow;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.compiletime.DSLParser;
import hex.core.IApplicationContext;
import hex.core.IBuilder;
import hex.factory.BuildRequest;

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
	var _applicationContextClass 		: {name: String, pos: Position};
	
	function new() 
	{
		super();
	}
	
	@final
	public function getApplicationContext() : IApplicationContext
	{
		return this._applicationAssembler.getApplicationContext( this._applicationContextName, this._applicationContextDefaultClass );
	}
	
	@final
	override public function setContextData( data : Expr ) : Void
	{
		if ( data != null )
		{
			this._contextData = data;
			this._findApplicationContextName( data );
			this._findApplicationContextClass( data );
			
			var applicationContext = this._applicationAssembler.getApplicationContext( this._applicationContextName, this._applicationContextDefaultClass );
			this._builder = this._applicationAssembler.getFactory( this._factoryClass, applicationContext );
		}
		else
		{
			Context.error( "Context data is null.", data.pos );
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
							case EBinop( OpAssign, _.expr => EConst(CIdent(ContextKeywordList.NAME)), e2 ) : true;
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
	
	function _findApplicationContextClass( data : Expr ) : Void
	{
		this._applicationContextClass = switch( data.expr )
		{
			case EMeta( entry, e ) if ( entry.name == ContextKeywordList.CONTEXT ):

				var name = null;
				
				var a = Lambda.filter( entry.params, function ( p ) 
					{ 
						return switch( p.expr ) 
						{
							case EBinop( OpAssign, _.expr => EConst(CIdent(ContextKeywordList.TYPE)), e2 ) : true;
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

				{name: name, pos: e.pos};
				
			case _ :
				null;
		}
	}
	
	function _getExpressions() : Array<Expr>
	{
		var e = this._contextData;

		switch( e.expr )
		{
			case EMeta( entry, _.expr => EBlock( exprs ) ) if ( entry.name == ContextKeywordList.CONTEXT ):
				return exprs;
			case _:
		}
		
		return [];
	}
}
#end