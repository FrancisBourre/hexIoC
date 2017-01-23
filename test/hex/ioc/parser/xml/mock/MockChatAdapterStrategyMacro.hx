package hex.ioc.parser.xml.mock;

#if (!neko || haxe_ver >= "3.3")
import hex.control.async.IAsyncCommand;
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
		this.add( MockChatEventAdapterStrategyCommand ).withPayload( new ExecutionPayload( this._message + ":" + url, String ) ).withCompleteHandler( this._end );
	}

	function _end( async : IAsyncCommand ) : Void
	{
		module.onMessage( async.getResult()[0] );
	}
}
#end