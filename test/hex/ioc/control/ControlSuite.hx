package hex.ioc.control;

/**
 * ...
 * @author Francis Bourre
 */
class ControlSuite
{
	@suite( "Control suite" )
    public var list : Array<Class<Dynamic>> = [BuildArrayCommandTest, BuildBooleanCommandTest, BuildClassCommandTest, BuildFloatCommandTest, BuildIntcommandTest, BuildNullCommandTest, BuildStringCommandTest, BuildUIntCommandTest];
}