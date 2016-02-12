package hex.ioc.core;

/**
 * ...
 * @author Francis Bourre
 */
class IoCCoreSuite
{
	@Suite( "Core" )
    public var list : Array<Class<Dynamic>> = [CoreFactoryTest];
}