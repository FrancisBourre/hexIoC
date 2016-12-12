package hex.compiler.parser.xml;

import haxe.macro.Context;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.parser.AbstractParserCommand;
import hex.ioc.parser.xml.XmlAssemblingExceptionReporter;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeXMLParser extends AbstractParserCommand
{
	var _importHelper 		: ClassImportHelper;
	var _exceptionReporter 	: XmlAssemblingExceptionReporter;
	
	public function new() 
	{
		super();
	}
	
	function _getRootApplicationContextName() : String
	{
		var xml : Xml					= this.getContextData().firstElement();
		var applicationContextName 	= xml.get( "name" );
		
		if ( applicationContextName == null )
		{
			this._exceptionReporter.throwMissingApplicationContextNameException( xml );
			return null;
		}
		else
		{
			return applicationContextName;
		}
	}
	
	@final
	public function setImportHelper( importHelper : ClassImportHelper ) : Void
	{
		this._importHelper = importHelper;
	}
	
	@final
	public function setExceptionReporter( exceptionReporter : XmlAssemblingExceptionReporter ) : Void
	{
		this._exceptionReporter = exceptionReporter;
	}
	
	@final
	override public function getApplicationContext( applicationContextClass : Class<AbstractApplicationContext> = null ) : AbstractApplicationContext
	{
		return this._applicationAssembler.getApplicationContext( this._getRootApplicationContextName() );
	}
	
	@final
	override public function setContextData( data : Dynamic ) : Void
	{
		if ( data != null )
		{
			if ( Std.is( data, Xml ) )
			{
				this._contextData = data;

			}
			else
			{
				Context.error( this + ".setContextData() failed. Data should be an instance of Xml.", Context.currentPos() );
			}
		}
		else
		{
			Context.error( this + ".setContextData() failed. Data was null.", Context.currentPos() );
		}
	}
	
	@final
	function getXMLContext() : Xml
	{
		return cast getContextData();
	}
}