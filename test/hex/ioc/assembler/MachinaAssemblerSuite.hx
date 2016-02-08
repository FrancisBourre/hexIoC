package hex.ioc.assembler;

/**
 * ...
 * @author Francis Bourre
 */
class MachinaAssemblerSuite
{
	@Suite( "Assembler" )
    public var list : Array<Class<Dynamic>> = [ApplicationAssemblerTest, ApplicationContextTest];
}