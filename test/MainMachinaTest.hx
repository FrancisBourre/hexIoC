package;

import hex.HexMachinaSuite;
import hex.unittest.notifier.ConsoleNotifier;
import hex.unittest.runner.ExMachinaUnitCore;

/**
 * ...
 * @author Francis Bourre
 */
class MainMachinaTest
{
	static public function main() : Void
	{
		var emu : ExMachinaUnitCore = new ExMachinaUnitCore();
        emu.addListener( new ConsoleNotifier() );
        emu.addTest( HexMachinaSuite );
        emu.run();
	}
}