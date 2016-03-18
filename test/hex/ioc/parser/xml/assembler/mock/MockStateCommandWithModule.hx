package hex.ioc.parser.xml.assembler.mock;

import hex.di.ISpeedInjectorContainer;
import hex.control.command.BasicCommand;
import hex.control.Request;
import hex.log.Stringifier;
import hex.module.IModule;

/**
 * ...
 * @author Francis Bourre
 */
@:rtti
class MockStateCommandWithModule extends BasicCommand implements ISpeedInjectorContainer
{
	static public var callCount : Int = 0;
	static public var lastInjectedModule : IModule;
	
	@Inject
	public var module : IModule;
	
	override public function execute( ?request : Request ) : Void 
	{
		MockStateCommandWithModule.callCount++;
		MockStateCommandWithModule.lastInjectedModule = this.module;
		//trace( Stringifier.stringify( this.module ) );
	}
}