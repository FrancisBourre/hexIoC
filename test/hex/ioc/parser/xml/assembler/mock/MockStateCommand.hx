package hex.ioc.parser.xml.assembler.mock;

import hex.control.command.BasicCommand;
import hex.control.Request;
import hex.ioc.assembler.ApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
@:rtti
class MockStateCommand extends BasicCommand
{
	@Inject
	public var context : ApplicationContext;
	
	override public function execute( ?request : Request ) : Void 
	{
		trace( this.context.getCurrentState().toString() );
	}
}