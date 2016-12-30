package hex.compiler.parser.xml;

import haxe.macro.Context;
import hex.ioc.assembler.AbstractApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractXmlParser extends DSLParser<Xml>
{
	var _applicationContextName 		: String;
	//var _applicationContextClassName 	: String;
	
	function new() 
	{
		super();
	}
	
	@final
	override public function getApplicationContext() : AbstractApplicationContext
	{
		return this._applicationAssembler.getApplicationContext( this._applicationContextName );
	}
	
	@final
	override public function setContextData( data : Xml ) : Void
	{
		if ( data != null )
		{
			if ( Std.is( data, Xml ) )
			{
				this._contextData = data;
				this._findApplicationContextName( data );
				
				var context = this._applicationAssembler.getApplicationContext( this._applicationContextName );
				this._proxyFactory = this._applicationAssembler.getContextFactory( context );
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
	
	function _findApplicationContextName( xml : Xml ) : Void
	{
		this._applicationContextName = xml.firstElement().get( "name" );
		
		if ( this._applicationContextName == null )
		{
			Context.error( "Fails to retrieve applicationContext name. You should add 'name' attribute to the root of your xml context", 
			this._exceptionReporter.getPosition( xml  ) );
		}
	}
	
	function _throwMissingTypeException( type : String, xml : Xml, attributeName : String ) : Void 
	{
		Context.error( "Type not found '" + type + "' ", this._exceptionReporter.getPosition( xml, attributeName ) );
	}
}