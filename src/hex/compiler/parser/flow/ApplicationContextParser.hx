package hex.compiler.parser.flow;

import hex.ioc.core.ContextAttributeList;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextParser extends AbstractExprParser
{
	public function new() 
	{
		super();
	}
	
	override public function parse() : Void
	{
		//Create runtime applicationContext
		var assemblerExpr	= ( cast this._applicationAssembler ).getAssemblerExpression();
		
		var applicationContextClass = null;
		var applicationContextClassName = this._applicationContextClassName;
		
		if ( applicationContextClassName != null )
		{
			try
			{
				applicationContextClass = MacroUtil.getPack( applicationContextClassName );
			}
			catch ( error : Dynamic )
			{
				this._throwMissingApplicationContextClassException();
			}
		}
	
		var applicationContextName = this._applicationContextName;
	
		var expr;
		if ( applicationContextClass != null )
		{
			expr = macro @:mergeBlock { var applicationContext = $assemblerExpr.getApplicationContext( $v { applicationContextName }, $p { applicationContextClass } ); };
		}
		else
		{
			expr = macro @:mergeBlock { var applicationContext = $assemblerExpr.getApplicationContext( $v { applicationContextName } ); };
		}

		( cast this._applicationAssembler ).addExpression( expr );
	}
}