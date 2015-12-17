package hex.ioc.parser.xml.mock;

import hex.control.payload.PayloadEvent;
import hex.event.AdapterStrategy;

/**
 * ...
 * @author Francis Bourre
 */
@:rtti
class MockChatEventAdapterStrategyWithInjection extends AdapterStrategy
{
	@inject("name=parser")
	public var parser : IMockMessageParserModule;
		
	public function new() 
	{
		super( this, this.onAdapt );
	}
	
	public function onAdapt( args : Array<Dynamic> ) : Array<Dynamic>
	{
		var e : PayloadEvent = args[0];
		var message : String = e.getExecutionPayloads()[0].getData();
		return [ parser.parse( message ) ];
	}
}