package;

import hex.HexIoCSuite;
import hex.unittest.runner.ExMachinaUnitCore;

/**
 * ...
 * @author Francis Bourre
 */
class MainIoCTest
{
	static public function main() : Void
	{
		var emu = new ExMachinaUnitCore();
        
		#if flash
		emu.addListener( new hex.unittest.notifier.TraceNotifier( flash.Lib.current.loaderInfo, false, true ) );
		#elseif (php && haxe_ver < 4.0)
		emu.addListener( new hex.unittest.notifier.TraceNotifier( ) );
		#else
		emu.addListener( new hex.unittest.notifier.ConsoleNotifier( ) );
		#end
		
        emu.addTest( HexIoCSuite );
        emu.run();
	}
}
