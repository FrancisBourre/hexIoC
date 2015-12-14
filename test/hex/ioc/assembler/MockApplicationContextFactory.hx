package hex.ioc.assembler;

/**
 * ...
 * @author Francis Bourre
 */
class MockApplicationContextFactory
{

	private function new() 
	{
		
	}
	
	static public function getMockApplicationContext( applicationAssembler : IApplicationAssembler, name : String ) : ApplicationContext
	{
		return new ApplicationContext( applicationAssembler, name );
	}
	
}