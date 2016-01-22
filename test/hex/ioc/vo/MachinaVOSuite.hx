package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class MachinaVOSuite
{
	@Suite( "VO" )
    public var list : Array<Class<Dynamic>> = [PropertyVOTest];
}