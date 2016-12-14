package hex.compiler.parser.flow;

import haxe.macro.Context;
import haxe.macro.Expr;
import hex.ioc.assembler.AbstractApplicationContext;

using hex.util.MacroUtil;


/**
 * ...
 * @author Francis Bourre
 */
class AbstractExprParser extends DSLParser<Expr>
{
	function new() 
	{
		super();
	}
	
	function _getRootApplicationContextName() : String
	{
		var exprs = this._getExpressions();
		
		var i = exprs.iterator();
		while ( i.hasNext() )
		{
			var e = i.next();
			switch ( e.expr )
			{
				case ECall( _.expr => EConst( CIdent( _ => "context" ) ), params ):
					return params[ 0 ].expr.getStringFromExpr();
				case _:
					
			}
		}

		return null;
	}
	
	function _getRootApplicationContextClassName() : String
	{
		var exprs = this._getExpressions();
		
		var i = exprs.iterator();
		while ( i.hasNext() )
		{
			var e = i.next();
			switch ( e.expr )
			{
				case ECall( _.expr => EConst( CIdent( _ => "context" ) ), params ):
					return null;
					//return ( params.length > 1 ) ? params[ 1 ] : null;
				case _:
					
			}
		}

		return null;
	}
	
	@final
	override public function getApplicationContext( applicationContextClass : Class<AbstractApplicationContext> = null ) : AbstractApplicationContext
	{
		return this._applicationAssembler.getApplicationContext( this._getRootApplicationContextName() );
	}
	
	@final
	override public function setContextData( data : Expr ) : Void
	{
		if ( data != null )
		{
			this._contextData = data;
		}
		else
		{
			Context.error( "Context data is null.", Context.currentPos() );
		}
	}
	
	function _getExpressions() : Array<Expr>
	{
		var e = this.getContextData();
		switch( e.expr )
		{
			case EBlock( exprs ):
				return exprs;
			case _:
		}
		
		return [];
	}
}