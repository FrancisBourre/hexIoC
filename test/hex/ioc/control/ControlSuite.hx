package hex.ioc.control;

/**
 * ...
 * @author Francis Bourre
 */
class ControlSuite
{
	@suite( "Control suite" )
    public var list : Array<Class<Dynamic>> = [BuildFloatCommandTest, BuildIntcommandTest, BuildNullCommandTest, BuildStringCommandTest, BuildUIntCommandTest];
}