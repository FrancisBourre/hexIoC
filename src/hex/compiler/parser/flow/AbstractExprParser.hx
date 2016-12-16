package hex.compiler.parser.flow;

import haxe.macro.Context;
import haxe.macro.Expr;
import hex.ioc.assembler.AbstractApplicationContext;

using hex.util.MacroUtil;
using hex.compiler.parser.flow.ExpressionUtil;

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
	
	/*function _getRootApplicationContextName() : String
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
	}*/
	
	function _getRootApplicationContextName() : String
	{
		var data = this.getContextData();
		var applicationContextName = switch( data.expr )
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
		
		return applicationContextName;
	}
	
	function _getRootApplicationContextClassName() : String
	{
		var data = this.getContextData();
		var applicationContextClassName = switch( data.expr )
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
		
		return applicationContextClassName;
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
			case EMeta( entry, _.expr => EBlock( exprs ) ) if ( entry.name == "context" ):
				return exprs;
			case _:
		}
		
		return [];
	}
}