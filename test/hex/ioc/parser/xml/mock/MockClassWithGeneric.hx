package hex.ioc.parser.xml.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockClassWithGeneric<T> implements IMockInterfaceWithGeneric<T>
{
	public var property : T;
	
	public function new( o : T ) 
	{
		this.property = o;
	}
}