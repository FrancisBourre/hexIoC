package hex.mock;

import hex.control.trigger.Command;

/**
 * ...
 * @author Francis Bourre
 */
class SayHelloCommand extends Command<String>
{
	@Inject
	public var who : String;
	
	@Inject( 'receiver' )
	public var receiver : IMessageReceiver;
	
	public function new() 
	{
		super();
	}
	
	override public function execute() : Void 
	{
		var message = "hello " + this.who ;
		this.receiver.receive( message );
		this._complete( message );
	}
}