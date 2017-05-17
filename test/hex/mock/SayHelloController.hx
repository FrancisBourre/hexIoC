package hex.mock;

import hex.control.async.Expect;
import hex.control.trigger.ICommandTrigger;

/**
 * ...
 * @author Francis Bourre
 */
class SayHelloController implements ICommandTrigger
{
	static var TEST = "name";
	
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
	
	public function sayHelloWithFunctionInjectionWithName() : Void
	{
		@Inject( 'name' )
		var sayHelloTo : String->Expect<String>;
		sayHelloTo( 'world' );
	}
	
	public function sayHelloWithFunctionInjectionWithConstantName() : Void
	{
		@Inject( TEST )
		var sayHelloTo : String->Expect<String>;
		sayHelloTo( 'world' );
	}
	
	public function sayHelloWithFunctionInjectionWithConstantNameFromOtherClass() : Void
	{
		@Inject( Constants.TEST )
		var sayHelloTo : String->Expect<String>;
		sayHelloTo( 'world' );
	}
	
	public function sayHelloWithFunctionInjectionWithConstantNameFromOtherClassWithFQCN() : Void
	{
		@Inject( hex.mock.SayHelloController.Constants.TEST )
		var sayHelloTo : String->Expect<String>;
		sayHelloTo( 'world' );
	}
}

class Constants
{
	public static var TEST = "name";
}