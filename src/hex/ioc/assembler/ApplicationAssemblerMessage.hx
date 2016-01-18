package hex.ioc.assembler;
import hex.event.MessageType;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationAssemblerMessage
{
	static public var ASSEMBLING_START 			: MessageType = new MessageType( "onAssemblingStart" );
	static public var CONTEXT_PARSED 			: MessageType = new MessageType( "onContextParsed" );
	static public var OBJECTS_BUILT 			: MessageType = new MessageType( "onObjectsBuilt" );
	static public var METHODS_CALLED 			: MessageType = new MessageType( "onMethodsCalled" );
	static public var DOMAIN_LISTENERS_ASSIGNED : MessageType = new MessageType( "onDomainListenersAssigned" );
	static public var MODULES_INITIALIZED 		: MessageType = new MessageType( "onModulesInitialized" );
	static public var ASSEMBLING_END 			: MessageType = new MessageType( "onAssemblingEnd" );
	
	private function new() 
	{
		
	}
}