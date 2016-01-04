package hex.ioc.parser.xml.mock;

import hex.service.ServiceConfiguration;
import hex.service.ServiceEvent;
import hex.service.stateless.StatelessService;

/**
 * ...
 * @author Francis Bourre
 */
@:rtti
class AnotherMockAmazonService extends StatelessService<ServiceEvent, ServiceConfiguration> implements IMockAmazonService
{
	public function new() 
	{
		super();
	}
	
	@postConstruct
	override public function createConfiguration() : Void
	{
		//do nothing
	}
	
	public function getBooks() : Array<Dynamic> 
	{
		return [];
	}
}