package hex.ioc.parser.xml.mock;

import hex.control.payload.ExecutionPayload;
import hex.control.payload.PayloadEvent;
import hex.service.ServiceConfiguration;
import hex.service.ServiceEvent;
import hex.service.stateful.StatefulService;

/**
 * ...
 * @author Francis Bourre
 */
class MockStubStatefulService extends StatefulService<ServiceEvent, ServiceConfiguration> implements IMockStubStatefulService
{
	public static inline var INT_VO_UPDATE 			: String = "onIntVOUpdate";
	public static inline var BOOLEAN_VO_UPDATE 		: String = "onBooleanVOUpdate";
		
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
		this.getDispatcher().dispatchEvent( new PayloadEvent( MockStubStatefulService.INT_VO_UPDATE, this, [new ExecutionPayload(vo, MockIntVO)] ) );
	}

	public function setBooleanVO( vo : MockBooleanVO ) : Void
	{
		this._booleanVO = vo;
		this.getDispatcher().dispatchEvent( new PayloadEvent( MockStubStatefulService.BOOLEAN_VO_UPDATE, this, [new ExecutionPayload(vo, MockBooleanVO )] ) );
	}
}