package hex.ioc.parser.xml.mock;

import hex.di.IInjectorContainer;

/**
 * ...
 * @author Francis Bourre
 */
class MockClassWithInjectedProperty implements IInjectorContainer
{
	@Inject
	public var property : String;
	
	public function new() 
	{
		
	}
}