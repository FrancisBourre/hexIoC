package hex.ioc.parser.xml.mock;

import hex.service.ServiceConfiguration;
import hex.service.stateful.StatefulService;

/**
 * ...
 * @author Francis Bourre
 */
class MockFacebookService extends StatefulService<ServiceConfiguration> implements IMockFacebookService
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
	
	public function getFriends() : Array<Dynamic> 
	{
		return [];
	}
}