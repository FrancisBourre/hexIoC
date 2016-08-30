package hex.ioc.parser.xml.mock;

import hex.control.async.AsyncHandler;
import hex.control.async.IAsyncCommand;
import hex.control.payload.ExecutionPayload;
import hex.event.MacroAdapterStrategy;

/**
 * ...
 * @author Francis Bourre
 */
class MockChatEventAdapterStrategyMacro extends MacroAdapterStrategy
{
	var _message : String;

	public var url : String = "http://google.com";

	public function new()
	{
		super( this, this.onAdapt );
	}

	public function onAdapt( message : String ) : Void
	{
		this._message = message;
	}

	override function _prepare() : Void
	{
		this.add( MockChatEventAdapterStrategyCommand ).withPayloads( [new ExecutionPayload(this._message + ":" + url, String)] ).withCompleteHandlers( new AsyncHandler( this, this._end ) );
	}

	function _end( async : IAsyncCommand ) : Void
	{
		var cmd : MockChatEventAdapterStrategyCommand = cast async;
		this._result = cmd.getResult();
	}
}