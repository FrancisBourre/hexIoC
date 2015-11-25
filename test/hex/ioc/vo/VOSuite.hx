package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class VOSuite
{
	@suite( "VO suite" )
    public var list : Array<Class<Dynamic>> = [PropertyVOTest];
}