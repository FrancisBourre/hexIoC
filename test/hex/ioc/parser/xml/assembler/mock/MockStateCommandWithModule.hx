package hex.ioc.parser.xml.assembler.mock;

import hex.control.command.BasicCommand;
import hex.control.Request;
import hex.log.Stringifier;
import hex.module.IModule;

/**
 * ...
 * @author Francis Bourre
 */
@:rtti
class MockStateCommandWithModule extends BasicCommand
{
	@Inject
	public var module : IModule;
	
	override public function execute( ?request : Request ) : Void 
	{
		trace( Stringifier.stringify( this.module ) );
	}
}