package hex.ioc.parser.xml.mock;

import hex.event.AdapterStrategy;

/**
 * ...
 * @author Francis Bourre
 */
class MockChatAdapterStrategy extends AdapterStrategy
{
	public function new() 
	{
		super( this, this.onAdapt );
	}
	
	public function onAdapt( args : Array<Dynamic> ) : Array<Dynamic>
	{
		return [ args[0], Date.now() ];
	}
}