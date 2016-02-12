package hex.ioc.assembler;

/**
 * ...
 * @author Francis Bourre
 */
class IoCAssemblerSuite
{
	@Suite( "Assembler" )
    public var list : Array<Class<Dynamic>> = [ApplicationAssemblerTest, ApplicationContextTest];
}