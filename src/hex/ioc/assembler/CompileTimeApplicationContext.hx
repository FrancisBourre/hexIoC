package hex.ioc.assembler;

import hex.compiler.core.CompileTimeCoreFactory;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeApplicationContext extends AbstractApplicationContext
{
	@:allow( hex.compiletime )
	function new( applicationContextName : String )
	{
		super( new CompileTimeCoreFactory(), applicationContextName );
	}
}