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
		var contextData 	= this.getContextData();
		
		var applicationContextClass = null;
		var applicationContextClassName = this._getRootApplicationContextClassName();
		
		if ( applicationContextClassName != null )
		{
			try
			{
				applicationContextClass = MacroUtil.getPack( applicationContextClassName );
			}
			catch ( error : Dynamic )
			{
				this._exceptionReporter.throwMissingTypeException( applicationContextClassName, contextData, ContextAttributeList.TYPE );
			}
		}
	
		var applicationContextName = this._getRootApplicationContextName();
	
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