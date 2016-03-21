package hex.ioc.parser.xml.mock;

import hex.service.ServiceConfiguration;
import hex.service.stateless.StatelessService;

/**
 * ...
 * @author Francis Bourre
 */
class AnotherMockAmazonService extends StatelessService<ServiceConfiguration> implements IMockAmazonService
{
	public function new() 
	{
		super();
	}
	
	@PostConstruct
	override public function createConfiguration() : Void
	{
		//do nothing
	}
	
	public function getBooks() : Array<Dynamic> 
	{
		return [];
	}
}