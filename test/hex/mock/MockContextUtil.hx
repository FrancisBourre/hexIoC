package hex.mock;
import hex.core.IApplicationContext;
import hex.di.IDependencyInjector;

/**
 * ...
 * @author Francis Bourre
 */
class MockContextUtil 
{
	function new() {}

	public static function getInjector( context : IApplicationContext ) return context.getInjector();
	
}