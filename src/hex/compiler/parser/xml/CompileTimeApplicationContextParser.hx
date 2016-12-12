package hex.compiler.parser.xml;

import haxe.macro.Expr;
import hex.compiler.assembler.CompileTimeApplicationAssembler;
import hex.compiler.parser.xml.ClassImportHelper;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.assembler.IApplicationAssembler;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.parser.xml.XmlAssemblingExceptionReporter;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeApplicationContextParser extends CompileTimeXMLParser
{
	//public var applicationAssemblerExpr : Expr;
	
	public function new( /*applicationAssemblerExpr	: Expr*/ ) 
	{
		//this.applicationAssemblerExpr 	= applicationAssemblerExpr;
		super();
	}
	
	override public function parse() : Void
	{
		//Create runtime applicationAssembler
		/*var applicationAssemblerTypePath 	= MacroUtil.getTypePath( Type.getClassName( ApplicationAssembler ) );
		var applicationAssemblerVarName 	= "";
		
		if ( this.applicationAssemblerExpr == null )
		{
			applicationAssemblerVarName = 'applicationAssembler';
			( cast this._applicationAssembler ).addExpression( macro @:mergeBlock { var $applicationAssemblerVarName = new $applicationAssemblerTypePath(); } );
			this.applicationAssemblerExpr = macro $i { applicationAssemblerVarName };
		}*/
		
		//Create runtime applicationContext
		var assemblerExpr	 	= ( cast this._applicationAssembler ).getAssemblerExpression();
		var xml : Xml 			= this.getContextData().firstElement();
		
		var applicationContextClass = null;
		var applicationContextClassName : String = xml.get( ContextAttributeList.TYPE );
		
		if ( applicationContextClassName != null )
		{
			try
			{
				applicationContextClass = MacroUtil.getPack( applicationContextClassName );
			}
			catch ( error : Dynamic )
			{
				this._exceptionReporter.throwMissingTypeException( applicationContextClassName, xml, ContextAttributeList.TYPE );
			}
		}
		
		var applicationContextName : String = this._getRootApplicationContextName();
		
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