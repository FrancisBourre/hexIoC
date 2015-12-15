package hex.ioc.parser.xml;
import hex.error.IllegalArgumentException;
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
			if ( Std.is( data, Xml ) )
			{
				this._contextData 			= data;
				this._applicationContext 	= applicationContext;
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