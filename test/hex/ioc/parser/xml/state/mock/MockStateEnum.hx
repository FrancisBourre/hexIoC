package hex.ioc.parser.xml.state.mock;

import hex.state.State;

/**
 * ...
 * @author Francis Bourre
 */
class MockStateEnum
{
	static public var INITIAL_STATE : State = new State( "initial" );
	static public var NEXT_STATE 	: State = new State( "nextState" );
		
	function new() 
	{
		
	}
}