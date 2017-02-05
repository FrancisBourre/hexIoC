package hex.compiler.parser.xml;
import hex.compiletime.xml.AbstractXmlParser;
import hex.factory.BuildRequest;

#if macro
import hex.ioc.core.ContextAttributeList;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextParser extends AbstractXmlParser<BuildRequest>
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
		
		if ( this._applicationContextClass.name != null )
		{
			try
			{
				applicationContextClass = MacroUtil.getPack( this._applicationContextClass.name );
			}
			catch ( error : Dynamic )
			{
				this._exceptionReporter.report( "Type not found '" + this._applicationContextClass.name + "' ", 
												this._applicationContextClass.pos );
			}
		}
		else
		{
			applicationContextClass = MacroUtil.getPack( 'hex.ioc.assembler.ApplicationContext' );
		}
		
		var expr = macro @:mergeBlock { var applicationContext = $assemblerExpr.getApplicationContext( $v { this._applicationContextName }, $p { applicationContextClass } ); };
		( cast this._applicationAssembler ).addExpression( expr );
	}
}
#end