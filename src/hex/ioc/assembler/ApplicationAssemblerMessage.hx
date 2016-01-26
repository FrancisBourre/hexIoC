package hex.ioc.assembler;
import hex.event.MessageType;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationAssemblerMessage
{
	static public var CONTEXT_PARSED 			= new MessageType( "onContextParsed" );
	static public var ASSEMBLING_START 			= new MessageType( "onAssemblingStart" );
	static public var STATE_TRANSITIONS_BUILT 	= new MessageType( "onStateTransitionsBuilt" );
	static public var OBJECTS_BUILT 			= new MessageType( "onObjectsBuilt" );
	static public var METHODS_CALLED 			= new MessageType( "onMethodsCalled" );
	static public var DOMAIN_LISTENERS_ASSIGNED = new MessageType( "onDomainListenersAssigned" );
	static public var MODULES_INITIALIZED 		= new MessageType( "onModulesInitialized" );
	static public var ASSEMBLING_END 			= new MessageType( "onAssemblingEnd" );
	
	function new() 
	{
		
	}
}