package hex.ioc.parser.xml.mock;

import hex.service.stateless.IStatelessService;

/**
 * @author Francis Bourre
 */
interface IMockAmazonService extends IStatelessService
{
	function getBooks() : Array<Dynamic>;
}