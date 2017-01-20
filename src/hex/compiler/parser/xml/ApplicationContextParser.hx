package hex.compiler.parser.xml;

import hex.ioc.core.ContextAttributeList;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextParser extends AbstractXmlParser
{
	public function new() 
	{
		super();
	}
	
	override public function parse() : Void
	{
		//Create runtime applicationContext
		var assemblerExpr	 	= ( cast this._applicationAssembler ).getAssemblerExpression();

		var applicationContextClass = null;
		
		if ( this._applicationContextClassName != null )
		{
			try
			{
				applicationContextClass = MacroUtil.getPack( this._applicationContextClassName );
			}
			catch ( error : Dynamic )
			{
				this._throwMissingApplicationContextClassException();
			}
		}
		
		var expr;
		if ( applicationContextClass != null )
		{
			expr = macro @:mergeBlock { var applicationContext = $assemblerExpr.getApplicationContext( $v { this._applicationContextName }, $p { applicationContextClass } ); };
		}
		else
		{
			expr = macro @:mergeBlock { var applicationContext = $assemblerExpr.getApplicationContext( $v { this._applicationContextName } ); };
		}

		( cast this._applicationAssembler ).addExpression( expr );
	}
}