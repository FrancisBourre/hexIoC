package hex.ioc.parser.xml.mock;

import hex.control.payload.PayloadEvent;
import hex.event.AdapterStrategy;

/**
 * ...
 * @author Francis Bourre
 */
@:rtti
class MockIntDividerEventAdapterStrategy extends AdapterStrategy
{
	@inject("name=mockDividerHelper")
	public var helper : IMockDividerHelper;

	public function new()
	{
		super( this, this.onAdapt );
	}

	public function onAdapt( args : Array<Dynamic> ) : Array<Dynamic>
	{
		var e : PayloadEvent = args[ 0 ];
		var mockIntVO : MockIntVO = e.getExecutionPayloads()[0].getData();
		var result : Float = helper.divide( mockIntVO.value, 2 );
		return [ result ];
	}
}