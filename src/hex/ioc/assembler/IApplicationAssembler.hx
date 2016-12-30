package hex.ioc.assembler;

import hex.factory.IProxyFactory;
import hex.ioc.core.IContextFactory;

/**
 * @author Francis Bourre
 */
interface IApplicationAssembler
{
	function getProxyFactory( applicationContext : AbstractApplicationContext ) : IProxyFactory;
	function getContextFactory( applicationContext : AbstractApplicationContext ) : IContextFactory;
	function buildEverything() : Void;
	function release() : Void;
	function getApplicationContext( applicationContextName : String, applicationContextClass : Class<AbstractApplicationContext> = null ) : AbstractApplicationContext;
}