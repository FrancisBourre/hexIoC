package hex.ioc.parser.xml.assembler.mock;

import hex.event.IDispatcher;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.core.ICoreFactory;

/**
 * ...
 * @author Francis Bourre
 */
class MockApplicationContext extends ApplicationContext
{
	public function new( dispatcher : IDispatcher<{}>, coreFactory : ICoreFactory, applicationContextName : String ) 
	{
		super( dispatcher, coreFactory, applicationContextName );
	}
	
	override function _initStateList():Void 
	{
		this.state = new MockApplicationContextStateList();
	}
	
	public function fireApplicationInit() : Void
	{
		this.dispatch( MockStateContextMessage.APPLICATION_INIT );
	}
	
	public function fireSwitchState() : Void
	{
		this.dispatch( MockStateContextMessage.SWITCH_STATE );
	}
	
	public function fireSwitchBack() : Void
	{
		this.dispatch( MockStateContextMessage.SWITCH_BACK );
	}
}