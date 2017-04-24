package hex.mock;

import hex.control.async.Expect;
import hex.control.trigger.ICommandTrigger;

/**
 * ...
 * @author Francis Bourre
 */
class SayHelloExternalController implements ICommandTrigger
{
	public function new() {}
	
	@Map( SayHelloCommand )
	public function sayHelloTo( who: String ) : Expect<String>;
}