package hex.mock;

import hex.control.async.Expect;
import hex.control.trigger.ICommandTrigger;

/**
 * ...
 * @author Francis Bourre
 */
class SayHelloController implements ICommandTrigger
{
	public function new() {}
	
	public function sayHelloWithControllerInjection() : Void
	{
		@Inject
		var sender : MessageSenderTypeDef;
		sender.sayHelloTo( 'world' );
	}
	
	public function sayHelloWithFunctionInjection() : Void
	{
		@Inject
		var sayHelloTo : String->Expect<String>;
		sayHelloTo( 'world' );
	}
}