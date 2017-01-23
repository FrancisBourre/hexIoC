package hex.ioc.parser.xml;

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
		//Build applicationContext for the 1st time
		this.getApplicationContext();
	}
}