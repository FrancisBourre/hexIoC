package hex.ioc.assembler;

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