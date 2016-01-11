package hex.ioc.parser.xml.mock;

import hex.service.stateful.IStatefulService;

/**
 * ...
 * @author Francis Bourre
 */
interface IMockFacebookService extends IStatefulService
{
	function getFriends() : Array<Dynamic>;
}