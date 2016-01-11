package hex.ioc.parser.xml.mock;

import hex.event.MessageType;
import hex.service.stateful.StatefulService;

/**
 * ...
 * @author Francis Bourre
 */
class MockStubStatefulService extends StatefulService implements IMockStubStatefulService
{
	public static var INT_VO_UPDATE 			: MessageType = new MessageType( "onIntVOUpdate" );
	public static var BOOLEAN_VO_UPDATE 		: MessageType = new MessageType( "onBooleanVOUpdate" );
		
	private var _intVO 		: MockIntVO;
	private var _booleanVO 	: MockBooleanVO;
		
	public function new() 
	{
		super();
	}
	
	@postConstruct
	override public function createConfiguration() : Void
	{
		//do nothing
	}
	
	public function setIntVO( vo : MockIntVO ) : Void
	{
		this._intVO = vo;
		this.getDispatcher().dispatch( MockStubStatefulService.INT_VO_UPDATE, [ vo ] );
	}

	public function setBooleanVO( vo : MockBooleanVO ) : Void
	{
		this._booleanVO = vo;
		this.getDispatcher().dispatch( MockStubStatefulService.BOOLEAN_VO_UPDATE, [ vo ] );
	}
}