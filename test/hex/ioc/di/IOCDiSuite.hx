package hex.ioc.di;

/**
 * ...
 * @author Francis Bourre
 */
class IOCDiSuite
{
	@Suite( "Di" )
    public var list : Array<Class<Dynamic>> = [ MappingConfigurationTest ];
}