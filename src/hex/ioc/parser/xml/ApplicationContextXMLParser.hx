package hex.ioc.parser.xml;

import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.error.ParsingException;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextXMLParser extends AbstractXMLParser
{
	public function new() 
	{
		super();
	}
	
	override public function parse() : Void
	{
		//Build applicationContext class for the 1st time
		var applicationContextClassName : String = this.getXMLContext().firstElement().get( "type" );

		if ( applicationContextClassName != null )
		{
			try
			{
				var applicationContextClass : Class<AbstractApplicationContext> = cast Type.resolveClass( applicationContextClassName );
				this.getApplicationContext( applicationContextClass );
			}
			catch ( error : Dynamic )
			{
				throw new ParsingException( this + " failed to instantiate applicationContext class named '" + applicationContextClassName + "'" );
			}
		}
		else
		{
			this.getApplicationContext();
		}
		
		this._handleComplete();
	}
}