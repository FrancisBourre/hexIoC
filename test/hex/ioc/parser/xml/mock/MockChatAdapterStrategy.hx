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
	
	public function onAdapt( s : String ) : Array<Dynamic>
	{
		return [s, Date.now() ];
	}
}