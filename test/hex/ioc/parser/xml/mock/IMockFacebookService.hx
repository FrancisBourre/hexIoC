package hex.ioc.parser.xml.mock;

import hex.service.ServiceConfiguration;
import hex.service.stateful.IStatefulService;

/**
 * ...
 * @author Francis Bourre
 */
interface IMockFacebookService extends IStatefulService<ServiceConfiguration>
{
	function getFriends() : Array<Dynamic>;
}