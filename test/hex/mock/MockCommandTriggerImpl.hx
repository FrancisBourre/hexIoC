package hex.mock;

import hex.control.trigger.ICommandTrigger;

/**
 * ...
 * @author Francis Bourre
 */
class MockCommandTriggerImpl implements ICommandTrigger
{
	@Inject
	public var test : String;
	
	@Inject( 'i' )
	public var i : Int;

	public function new() 
	{
		
	}
	
}