package hex.ioc.parser.xml.mock;

import hex.di.ISpeedInjectorContainer;
import haxe.Timer;
import hex.control.async.AsyncCommand;
import hex.control.Request;

/**
 * ...
 * @author Francis Bourre
 */
class MockChatEventAdapterStrategyCommand extends AsyncCommand implements ISpeedInjectorContainer
{
	public function new() 
	{
		super();
	}
	
	@Inject( "parser" )
	public var parser : IMockMessageParserModule;

	@Inject
	public var message : String;

	override public function execute( ?request : Request ) : Void
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