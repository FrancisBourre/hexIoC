package hex.ioc.assembler;

import hex.core.IBuilder;

/**
 * @author Francis Bourre
 */
interface IApplicationAssembler
{
	function getBuilder<T>( applicationContext : AbstractApplicationContext ) : IBuilder<T>;
	function buildEverything() : Void;
	function release() : Void;
	function getApplicationContext( applicationContextName : String, applicationContextClass : Class<AbstractApplicationContext> = null ) : AbstractApplicationContext;
}