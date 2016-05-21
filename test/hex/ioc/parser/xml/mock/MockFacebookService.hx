package hex.ioc.parser.xml.mock;

import hex.service.stateful.StatefulService;

/**
 * ...
 * @author Francis Bourre
 */
class MockFacebookService extends StatefulService implements IMockFacebookService
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
	
	public function getFriends() : Array<Dynamic> 
	{
		return [];
	}
}