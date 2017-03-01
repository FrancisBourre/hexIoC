package hex.mock;

import hex.event.ITrigger;
import hex.event.ITriggerOwner;

/**
 * ...
 * @author Francis Bourre
 */
class MockWeatherModel implements ITriggerOwner
{

	public var weather( default, never )  : ITrigger<String->Void>;
	public var temperature( default, never )  : ITrigger<Int->Void>;
	
	public function new() {}
}