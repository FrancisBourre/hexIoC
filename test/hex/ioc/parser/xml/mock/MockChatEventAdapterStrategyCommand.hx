package hex.ioc.parser.xml.mock;

import haxe.Timer;
import hex.control.async.AsyncCommand;

/**
 * ...
 * @author Francis Bourre
 */
class MockChatEventAdapterStrategyCommand extends AsyncCommand
{
	public function new() 
	{
		super();
	}
	
	@Inject( "parser" )
	public var parser : IMockMessageParserModule;

	@Inject
	public var message : String;

	override public function execute() : Void
	{
		Timer.delay( this.testAsyncCallback, 300 );
	}
	
	override public function getResult() : Array<Dynamic> 
	{
		var message : String = this.parser.parse( this.message );
		return [ message ];
	}

	function testAsyncCallback() : Void
	{
		this._handleComplete();
	}
}