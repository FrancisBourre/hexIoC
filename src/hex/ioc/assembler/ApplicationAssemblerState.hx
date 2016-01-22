package hex.ioc.assembler;

import hex.state.State;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationAssemblerState
{
	static public var CONTEXT_INITIALIZED 		: State = new State( "onContextInitialized" );
	static public var CONTEXT_PARSED 			: State = new State( "onContextParsed" );
	static public var STATE_TRANSITIONS_BUILT 	: State = new State( "onStateTransitionsBuilt" );
	static public var ASSEMBLING_START 			: State = new State( "onAssemblingStart" );
	static public var OBJECTS_BUILT 			: State = new State( "onObjectsBuilt" );
	static public var DOMAIN_LISTENERS_ASSIGNED : State = new State( "onDomainListenersAssigned" );
	static public var METHODS_CALLED 			: State = new State( "onMethodsCalled" );
	static public var MODULES_INITIALIZED 		: State = new State( "onModulesInitialized" );
	static public var ASSEMBLING_END 			: State = new State( "onAssemblingEnd" );
	
	private static var _IS_INITIALIZED 			: Bool = ApplicationAssemblerState._init();
	
	private function new() 
	{
		
	}
	
	private static function _init() : Bool
	{
		if ( !ApplicationAssemblerState._IS_INITIALIZED )
		{
			ApplicationAssemblerState.CONTEXT_INITIALIZED.addTransition( ApplicationAssemblerMessage.CONTEXT_PARSED, ApplicationAssemblerState.CONTEXT_PARSED );
			ApplicationAssemblerState.CONTEXT_PARSED.addTransition( ApplicationAssemblerMessage.STATE_TRANSITIONS_BUILT, ApplicationAssemblerState.STATE_TRANSITIONS_BUILT );
			ApplicationAssemblerState.STATE_TRANSITIONS_BUILT.addTransition( ApplicationAssemblerMessage.ASSEMBLING_START, ApplicationAssemblerState.ASSEMBLING_START );
			ApplicationAssemblerState.ASSEMBLING_START.addTransition( ApplicationAssemblerMessage.OBJECTS_BUILT, ApplicationAssemblerState.OBJECTS_BUILT );
			ApplicationAssemblerState.OBJECTS_BUILT.addTransition( ApplicationAssemblerMessage.DOMAIN_LISTENERS_ASSIGNED, ApplicationAssemblerState.DOMAIN_LISTENERS_ASSIGNED );
			ApplicationAssemblerState.DOMAIN_LISTENERS_ASSIGNED.addTransition( ApplicationAssemblerMessage.METHODS_CALLED, ApplicationAssemblerState.METHODS_CALLED );
			ApplicationAssemblerState.METHODS_CALLED.addTransition( ApplicationAssemblerMessage.MODULES_INITIALIZED, ApplicationAssemblerState.MODULES_INITIALIZED );
			ApplicationAssemblerState.MODULES_INITIALIZED.addTransition( ApplicationAssemblerMessage.ASSEMBLING_END, ApplicationAssemblerState.ASSEMBLING_END );
		}
		
		return true;
	}
}