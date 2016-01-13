package hex.ioc.parser.xml.state.mock;

import hex.config.stateful.IStatefulConfig;
import hex.module.Module;

/**
 * ...
 * @author Francis Bourre
 */
class MockModuleWorkingWithStates extends Module
{
	public var commandWasCalled : Bool = false;
	
	public function new( stateConfig : IStatefulConfig ) 
	{
		super();
		this._addStatefulConfigs( [ stateConfig ] );
	}
	
	override private function _onInitialisation() : Void 
	{
		this._dispatchPrivateMessage( MockStateMessage.TRIGGER_NEXT_STATE );
		super._onInitialisation();
	}
}