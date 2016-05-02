package hex.ioc.parser.xml.mock;

import hex.di.IInjectorContainer;
import hex.event.AdapterStrategy;

/**
 * ...
 * @author Francis Bourre
 */
class MockIntDividerEventAdapterStrategy extends AdapterStrategy implements IInjectorContainer
{
	@Inject( "mockDividerHelper" )
	public var helper : IMockDividerHelper;

	public function new()
	{
		super( this, this.onAdapt );
	}

	public function onAdapt( mockIntVO : MockIntVO ) : Array<Dynamic>
	{
		var result : Float = helper.divide( mockIntVO.value, 2 );
		return [ result ];
	}
}