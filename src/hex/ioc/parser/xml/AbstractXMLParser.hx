package hex.ioc.parser.xml;
import hex.error.NullPointerException;
import hex.error.PrivateConstructorException;
import hex.ioc.assembler.ApplicationContext;
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
	override public function setContextData( data : Dynamic, applicationContext : ApplicationContext ) : Void
	{
		if ( data != null )
		{
			this._contextData 			= Xml.parse( data );
			this._applicationContext 	= applicationContext;
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