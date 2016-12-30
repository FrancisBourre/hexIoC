package hex.ioc.assembler;

import hex.ioc.core.IContextFactory;

/**
 * @author Francis Bourre
 */
interface IApplicationAssembler
{
	function getContextFactory( applicationContext : AbstractApplicationContext ) : IContextFactory;
	function buildEverything() : Void;
	function release() : Void;
	function getApplicationContext( applicationContextName : String, applicationContextClass : Class<AbstractApplicationContext> = null ) : AbstractApplicationContext;
}