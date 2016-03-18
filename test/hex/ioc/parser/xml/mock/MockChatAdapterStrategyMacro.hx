package hex.ioc.parser.xml.mock;

import hex.control.async.AsyncCommand;
import hex.control.async.AsyncHandler;
import hex.control.payload.ExecutionPayload;
import hex.event.MacroAdapterStrategy;

/**
 * ...
 * @author Francis Bourre
 */
class MockChatAdapterStrategyMacro extends MacroAdapterStrategy
{
	var _message : String;

	public var url : String = "http://google.com";
	
	@Inject( "receiver" )
	public var module : MockReceiverModule;

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

	function _end( async : AsyncCommand ) : Void
	{
		module.onMessage( async.getResult()[0] );
	}
}