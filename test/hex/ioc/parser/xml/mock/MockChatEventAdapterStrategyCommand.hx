package hex.ioc.parser.xml.mock;

import haxe.Timer;
import hex.control.async.AsyncCommand;
import hex.control.Request;

/**
 * ...
 * @author Francis Bourre
 */
@:rtti
class MockChatEventAdapterStrategyCommand extends AsyncCommand
{
	public function new() 
	{
		super();
	}
	
	@inject("name=parser")
	public var parser : IMockMessageParserModule;

	@inject
	public var message : String;

	override public function execute( ?request : Request ) : Void
	{
		Timer.delay( this.testAsyncCallback, 300 );
	}
	
	override public function getPayload() : Array<Dynamic> 
	{
		var message : String = this.parser.parse( this.message );
		return [ message ];
	}

	private function testAsyncCallback() : Void
	{
		this._handleComplete();
	}
}