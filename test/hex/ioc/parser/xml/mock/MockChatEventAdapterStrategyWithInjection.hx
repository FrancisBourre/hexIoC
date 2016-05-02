package hex.ioc.parser.xml.mock;

import hex.di.IInjectorContainer;
import hex.event.AdapterStrategy;

/**
 * ...
 * @author Francis Bourre
 */
class MockChatEventAdapterStrategyWithInjection extends AdapterStrategy implements IInjectorContainer
{
	@Inject( "parser" )
	public var parser : IMockMessageParserModule;
		
	public function new() 
	{
		super( this, this.onAdapt );
	}
	
	public function onAdapt( s : String ) : Array<Dynamic>
	{
		return [ parser.parse( s ) ];
	}
}