package hex.ioc.assembler;
import hex.core.IApplicationAssembler;

/**
 * ...
 * @author Francis Bourre
 */
class MockApplicationContextFactory
{

	function new() 
	{
		
	}
	
	static public function getMockApplicationContext( applicationAssembler : IApplicationAssembler, name : String ) : ApplicationContext
	{
		return new ApplicationContext( applicationAssembler, name );
	}
	
}