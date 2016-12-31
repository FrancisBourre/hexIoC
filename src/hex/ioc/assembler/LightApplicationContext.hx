package hex.ioc.assembler;

import hex.event.MessageType;
import hex.core.ICoreFactory;

/**
 * ...
 * @author Francis Bourre
 */
class LightApplicationContext extends AbstractApplicationContext
{
	@:allow( hex.ioc.core )
	function new( coreFactory : ICoreFactory, name : String )
	{
		super( coreFactory, name );
	}
	
	override public function dispatch( messageType : MessageType, ?data : Array<Dynamic> ) : Void
	{
		//do ntohing
	}
}