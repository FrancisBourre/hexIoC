package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class IoCVOSuite
{
	@Suite( "VO" )
    public var list : Array<Class<Dynamic>> = [PropertyVOTest];
}