package hex.ioc.parser.xml.mock;

import hex.service.stateless.StatelessService;

/**
 * ...
 * @author Francis Bourre
 */
@:rtti
class MockAmazonService extends StatelessService implements IMockAmazonService
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