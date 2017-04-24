package hex.mock;

import hex.control.async.Expect;

/**
 * @author Francis Bourre
 */
typedef MessageSenderTypeDef =
{
	function sayHelloTo( who : String ) : Expect<String>;	
}