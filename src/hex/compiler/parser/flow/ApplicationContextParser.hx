package hex.compiler.parser.flow;

#if macro
import hex.core.VariableExpression;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextParser extends hex.compiletime.flow.AbstractExprParser<hex.factory.BuildRequest>
{
	var _assemblerVariable : VariableExpression;
	
	public function new( assemblerVar : VariableExpression ) 
	{
		this._assemblerVariable = assemblerVar;
		super();
	}
	
	override public function parse() : Void
	{
		//Create runtime applicationAssembler
		var applicationAssemblerTypePath = MacroUtil.getTypePath( "hex.runtime.ApplicationAssembler" );

		if ( this._assemblerVariable.expression == null )
		{
			var applicationAssemblerVarName = this._assemblerVariable.name = 'applicationAssembler';
			( cast this._applicationAssembler ).addExpression( macro @:mergeBlock { var $applicationAssemblerVarName = new $applicationAssemblerTypePath(); } );
			this._assemblerVariable.expression = macro $i { applicationAssemblerVarName };
		}
		
		//Create runtime applicationContext
		var applicationContextClass = null;
		var applicationContextClassName = this._applicationContextClass.name;
		
		if ( applicationContextClassName != null )
		{
			try
			{
				applicationContextClass = MacroUtil.getPack( applicationContextClassName );
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
	
		var assemblerVarExpression = this._assemblerVariable.expression;
		var expr = macro @:mergeBlock { var applicationContext = $assemblerVarExpression.getApplicationContext( $v { this._applicationContextName }, $p { applicationContextClass } ); };
		( cast this._applicationAssembler ).addExpression( expr );
	}
}
#end