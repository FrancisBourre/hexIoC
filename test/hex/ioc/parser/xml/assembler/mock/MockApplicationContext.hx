package hex.ioc.parser.xml.assembler.mock;

import hex.ioc.assembler.ApplicationContext;
import hex.ioc.assembler.ApplicationContextStateList;
import hex.ioc.assembler.IApplicationAssembler;

/**
 * ...
 * @author Francis Bourre
 */
class MockApplicationContext extends ApplicationContext
{
	public function new( applicationAssembler : IApplicationAssembler, applicationContextName : String ) 
	{
		super( applicationAssembler, applicationContextName );
	}
	
	override function _initStateList():Void 
	{
		this.state = new MockApplicationContextStateList();
	}
	
	public function fireApplicationInit() : Void
	{
		this._dispatch( MockStateContextMessage.APPLICATION_INIT );
	}
	
	public function fireSwitchState() : Void
	{
		this._dispatch( MockStateContextMessage.SWITCH_STATE );
	}
	
	public function fireSwitchBack() : Void
	{
		this._dispatch( MockStateContextMessage.SWITCH_BACK );
	}
}