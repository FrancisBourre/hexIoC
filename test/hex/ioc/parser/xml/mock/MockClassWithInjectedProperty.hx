package hex.ioc.parser.xml.mock;

/**
 * ...
 * @author Francis Bourre
 */
@:rtti
class MockClassWithInjectedProperty
{
	@Inject
	public var property : String;
	
	public function new() 
	{
		
	}
}