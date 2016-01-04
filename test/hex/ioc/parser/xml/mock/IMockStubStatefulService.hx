package hex.ioc.parser.xml.mock;

import hex.service.ServiceConfiguration;
import hex.service.ServiceEvent;
import hex.service.stateful.IStatefulService;

/**
 * ...
 * @author Francis Bourre
 */
interface IMockStubStatefulService extends IStatefulService<ServiceEvent, ServiceConfiguration>
{
	function setIntVO( vo : MockIntVO ) : Void;
	function setBooleanVO( vo : MockBooleanVO ) : Void;
}