package hex.ioc.parser.xml.mock;

import hex.di.ISpeedInjectorContainer;
import hex.event.AdapterStrategy;

/**
 * ...
 * @author Francis Bourre
 */
@:rtti
class MockChatEventAdapterStrategyWithInjection extends AdapterStrategy implements ISpeedInjectorContainer
{
	@Inject( "parser" )
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