package hex.ioc.parser.xml;

import hex.error.IllegalArgumentException;
import hex.error.NullPointerException;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.error.ParsingException;
import hex.ioc.parser.AbstractParserCommand;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractXMLParser extends AbstractParserCommand
{
	private function new()
	{
		super();
	}
	
	@final
	override public function getApplicationContext( applicationContextClass : Class<ApplicationContext> = null ) : ApplicationContext
	{
		var applicationContextName : String = this.getXMLContext().firstElement().get( "name" );
		if ( applicationContextName == null )
		{
			throw new ParsingException( this + " failed to retrieve applicationContext name. You should add 'name' attribute to the root of your xml context" );
		}
		
		return this._applicationAssembler.getApplicationContext( applicationContextName, applicationContextClass );
	}
	
	@final
	override public function setContextData( data : Dynamic ) : Void
	{
		if ( data != null )
		{
			if ( Std.is( data, Xml ) )
			{
				this._contextData 			= data;

			}
			else
			{
				throw new IllegalArgumentException( this + ".setContext() failed. Data should be an instance of Xml." );
			}
		}
		else
		{
			throw new NullPointerException( this + ".setContext() failed. Data was null." );
		}
	}
	
	@final
	private function getXMLContext() : Xml
	{
		return cast getContextData();
	}
	
}