package hex.ioc.parser.xml.mock;

import hex.control.payload.PayloadEvent;
import hex.event.AdapterStrategy;

/**
 * ...
 * @author Francis Bourre
 */
@:rtti
class MockChatAdapterStrategy extends AdapterStrategy
{
	public function new() 
	{
		super( this, this.onAdapt );
	}
	
	public function onAdapt( args : Array<Dynamic> ) : Array<Dynamic>
	{
		var e : PayloadEvent = args[0];
		return [ e.getExecutionPayloads()[0].getData(), Date.now() ];
	}
}