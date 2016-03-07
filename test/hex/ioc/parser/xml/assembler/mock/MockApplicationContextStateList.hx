package hex.ioc.parser.xml.assembler.mock;

import hex.ioc.assembler.ApplicationContextStateList;
import hex.state.State;

/**
 * ...
 * @author Francis Bourre
 */
class MockApplicationContextStateList extends ApplicationContextStateList
{
	public var CUSTOM_STATE (default, null) 				: State = new State( "onCustomState" );
	public var ANOTHER_STATE (default, null) 	 			: State = new State( "onAnotherState" );
	
	public function new() 
	{
		super();
			
		this.ASSEMBLING_END.addTransition( MockStateContextMessage.APPLICATION_INIT, this.CUSTOM_STATE );
		this.CUSTOM_STATE.addTransition( MockStateContextMessage.SWITCH_STATE, this.ANOTHER_STATE );
		this.ANOTHER_STATE.addTransition( MockStateContextMessage.SWITCH_BACK, this.CUSTOM_STATE );
	}
}