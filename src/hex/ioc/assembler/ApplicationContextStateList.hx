package hex.ioc.assembler;

import hex.state.State;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextStateList
{
	public var CONTEXT_INITIALIZED (default, null) 				: State = new State( "onContextInitialized" );
	public var CONTEXT_PARSED (default, null) 	 				: State = new State( "onContextParsed" );
	public var STATE_TRANSITIONS_BUILT (default, null) 	 		: State = new State( "onStateTransitionsBuilt" );
	public var ASSEMBLING_START (default, null) 	 			: State = new State( "onAssemblingStart" );
	public var OBJECTS_BUILT (default, null) 	 				: State = new State( "onObjectsBuilt" );
	public var DOMAIN_LISTENERS_ASSIGNED (default, null) 	 	: State = new State( "onDomainListenersAssigned" );
	public var METHODS_CALLED (default, null) 	 				: State = new State( "onMethodsCalled" );
	public var MODULES_INITIALIZED (default, null) 	 			: State = new State( "onModulesInitialized" );
	public var ASSEMBLING_END (default, null) 					: State = new State( "onAssemblingEnd" );
	
	public function new() 
	{
		this.CONTEXT_INITIALIZED.addTransition( ApplicationAssemblerMessage.CONTEXT_PARSED, this.CONTEXT_PARSED );
		this.CONTEXT_PARSED.addTransition( ApplicationAssemblerMessage.STATE_TRANSITIONS_BUILT, this.STATE_TRANSITIONS_BUILT );
		this.STATE_TRANSITIONS_BUILT.addTransition( ApplicationAssemblerMessage.ASSEMBLING_START, this.ASSEMBLING_START );
		this.ASSEMBLING_START.addTransition( ApplicationAssemblerMessage.OBJECTS_BUILT, this.OBJECTS_BUILT );
		this.OBJECTS_BUILT.addTransition( ApplicationAssemblerMessage.DOMAIN_LISTENERS_ASSIGNED, this.DOMAIN_LISTENERS_ASSIGNED );
		this.DOMAIN_LISTENERS_ASSIGNED.addTransition( ApplicationAssemblerMessage.METHODS_CALLED, this.METHODS_CALLED );
		this.METHODS_CALLED.addTransition( ApplicationAssemblerMessage.MODULES_INITIALIZED, this.MODULES_INITIALIZED );
		this.MODULES_INITIALIZED.addTransition( ApplicationAssemblerMessage.ASSEMBLING_END, this.ASSEMBLING_END );
			
		this.ASSEMBLING_END.addTransition( ApplicationAssemblerMessage.STATE_TRANSITIONS_BUILT, this.STATE_TRANSITIONS_BUILT );
	}
}