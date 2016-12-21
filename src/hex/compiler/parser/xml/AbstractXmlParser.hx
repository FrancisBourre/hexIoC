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
			Context.error( "Fails to retrieve applicationContext name. You should add 'name' attribute to the root of your xml context", 
				this._exceptionReporter.getPosition( xml  ) );

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
	
	function _throwMissingTypeException( type : String, xml : Xml, attributeName : String ) : Void 
	{
		Context.error( "Type not found '" + type + "' ", this._exceptionReporter.getPosition( xml, attributeName ) );
	}
}