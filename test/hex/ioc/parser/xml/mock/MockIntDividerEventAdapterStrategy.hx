package hex.ioc.parser.xml.mock;

import hex.di.ISpeedInjectorContainer;
import hex.event.AdapterStrategy;

/**
 * ...
 * @author Francis Bourre
 */
@:rtti
class MockIntDividerEventAdapterStrategy extends AdapterStrategy implements ISpeedInjectorContainer
{
	@Inject( "mockDividerHelper" )
	public var helper : IMockDividerHelper;

	public function new()
	{
		super( this, this.onAdapt );
	}

	public function onAdapt( args : Array<Dynamic> ) : Array<Dynamic>
	{
		var mockIntVO : MockIntVO = args[ 0 ];
		var result : Float = helper.divide( mockIntVO.value, 2 );
		return [ result ];
	}
}