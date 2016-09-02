package hex.ioc.parser.xml.mock;

import hex.di.IInjectorContainer;
import hex.domain.Domain;

/**
 * ...
 * @author Francis Bourre
 */
class MockInjectee implements IInjectorContainer implements IMockInjectee
{
	@Inject
	public var domain : Domain;
	
	public function new() 
	{
		
	}
}