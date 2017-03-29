package hex.ioc.parser.xml.assembler.mock;

import hex.event.MacroAdapterStrategy;

/**
 * ...
 * @author Francis Bourre
 */
class MockBuildAdapterStrategyMacro extends MacroAdapterStrategy
{
	public function new()
	{
		super( this, this.onAdapt );
	}

	public function onAdapt( arg ) : Void
	{
		trace( arg );
	}

	override function _prepare() : Void
	{
		this.add( MockBuildContextCommand );
	}
}