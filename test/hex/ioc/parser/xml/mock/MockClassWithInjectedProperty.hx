package hex.ioc.parser.xml.mock;

import hex.di.ISpeedInjectorContainer;

/**
 * ...
 * @author Francis Bourre
 */
class MockClassWithInjectedProperty implements ISpeedInjectorContainer
{
	@Inject
	public var property : String;
	
	public function new() 
	{
		
	}
}