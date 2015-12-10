package hex.ioc.control;

/**
 * ...
 * @author Francis Bourre
 */
class MachinaControlSuite
{
	@suite( "Control" )
    public var list : Array<Class<Dynamic>> = [BuildArrayCommandTest, BuildBooleanCommandTest, BuildClassCommandTest, BuildFloatCommandTest, BuildIntcommandTest, BuildNullCommandTest, BuildStringCommandTest, BuildUIntCommandTest];
}