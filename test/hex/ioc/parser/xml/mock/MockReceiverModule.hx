package hex.ioc.parser.xml.mock;

import hex.core.IApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class MockReceiverModule extends MockModule
{
	public function new( context : IApplicationContext ) 
	{
		super( context );
	}
	
	public var message : String;

	public function onMessage( text : String ) : Void
	{
		this.message = text;
	}
	
	public function onMessageEvent( message : String ) : Void
	{
		this.message = message;
	}
	
	public function onMessageArgument( args : Array<String> ) : Void
	{
		this.message = args[ 0 ];
	}
}