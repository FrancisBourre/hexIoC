package hex.ioc.parser.xml.mock;

import hex.service.stateful.IStatefulService;

/**
 * ...
 * @author Francis Bourre
 */
interface IMockStubStatefulService extends IStatefulService
{
	function setIntVO( vo : MockIntVO ) : Void;
	function setBooleanVO( vo : MockBooleanVO ) : Void;
}