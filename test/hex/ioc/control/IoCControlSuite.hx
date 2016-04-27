package hex.ioc.control;

/**
 * ...
 * @author Francis Bourre
 */
class IoCControlSuite
{
	@Suite( "Control" )
    public var list : Array<Class<Dynamic>> = [ArrayFactoryTest, BoolFactoryTest, ClassFactoryTest, FloatFactoryTest, IntFactoryTest, NullFactoryTest, StringFactoryTest, UIntFactoryTest];
}