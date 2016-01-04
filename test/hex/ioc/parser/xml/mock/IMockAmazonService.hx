package hex.ioc.parser.xml.mock;

import hex.service.ServiceConfiguration;
import hex.service.ServiceEvent;
import hex.service.stateless.IStatelessService;

/**
 * @author Francis Bourre
 */
interface IMockAmazonService extends IStatelessService<ServiceEvent, ServiceConfiguration>
{
	function getBooks() : Array<Dynamic>;
}