package hex.ioc.parser.xml.mock;

import hex.event.AdapterStrategy;

/**
 * ...
 * @author Francis Bourre
 */
@:rtti
class MockChatEventAdapterStrategyWithInjection extends AdapterStrategy
{
	@inject("name=parser")
	public var parser : IMockMessageParserModule;
		
	public function new() 
	{
		super( this, this.onAdapt );
	}
	
	public function onAdapt( args : Array<Dynamic> ) : Array<Dynamic>
	{
		return [ parser.parse( args[0] ) ];
	}
}