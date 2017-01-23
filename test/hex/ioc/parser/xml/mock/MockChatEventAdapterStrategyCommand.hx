package hex.ioc.parser.xml.mock;

#if (!neko || haxe_ver >= "3.3")
import haxe.Timer;
import hex.control.Request;
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

	public function execute( ?request : Request ) : Void
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
#end