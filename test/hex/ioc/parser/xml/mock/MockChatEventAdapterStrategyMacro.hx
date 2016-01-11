package hex.ioc.parser.xml.mock;

import hex.control.async.AsyncCommandEvent;
import hex.control.payload.ExecutionPayload;
import hex.event.MacroAdapterStrategy;

/**
 * ...
 * @author Francis Bourre
 */
@:rtti
class MockChatEventAdapterStrategyMacro extends MacroAdapterStrategy
{
	private var _message : String;

	public var url : String = "http://google.com";

	public function new()
	{
		super( this, this.onAdapt );
	}

	public function onAdapt( message : String ) : Void
	{
		this._message = message;
	}

	override private function _prepare() : Void
	{
		this.add( MockChatEventAdapterStrategyCommand ).withPayloads( [new ExecutionPayload(this._message + ":" + url, String)] ).withCompleteHandlers( [this._end] );
	}

	private function _end( e : AsyncCommandEvent ) : Void
	{
		var cmd : MockChatEventAdapterStrategyCommand = cast e.getAsyncCommand();
		this._payload = cmd.getPayload();
		this._handleComplete();
	}
}