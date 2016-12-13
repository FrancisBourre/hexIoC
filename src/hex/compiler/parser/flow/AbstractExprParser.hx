package hex.compiler.parser.flow;

import haxe.macro.Context;
import haxe.macro.Expr;
import hex.ioc.assembler.AbstractApplicationContext;

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
		return 'applicationContext';
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
}