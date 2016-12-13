package hex.compiler.parser.xml;

import haxe.macro.Context;
import hex.ioc.assembler.AbstractApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractXmlParser extends DSLParser<Xml>
{
	function new() 
	{
		super();
	}
	
	function _getRootApplicationContextName() : String
	{
		var xml : Xml				= this.getContextData().firstElement();
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
				Context.error( "Context data should be an instance of Xml.", Context.currentPos() );
			}
		}
		else
		{
			Context.error( "Context data is null.", Context.currentPos() );
		}
	}
}