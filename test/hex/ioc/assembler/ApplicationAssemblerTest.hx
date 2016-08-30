package hex.ioc.assembler;

import hex.ioc.error.BuildingException;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationAssemblerTest
{
	//TODO move this tests to XmlDSLParser class
	
	/*@Test( "Test addConditionalProperty behavior" )
	public function testAddConditionalProperty( ) : Void
	{
		var assembler : ApplicationAssembler = new ApplicationAssembler();
		assembler.addConditionalProperty( ["production" => true, "debug" => false] );
		Assert.isTrue( assembler.allowsIfList( ["production"] ), "" );
		Assert.isFalse( assembler.allowsIfList( ["debug"] ), "" );
		Assert.isTrue( assembler.allowsIfList( ["debug", "production"] ), "" );
		Assert.isTrue( assembler.allowsIfList( ["production", "debug"] ), "" );
		
		Assert.isFalse( assembler.allowsIfNotList( ["production"] ), "" );
		Assert.isTrue( assembler.allowsIfNotList( ["debug"] ), "" );
		Assert.isFalse( assembler.allowsIfNotList( ["debug", "production"] ), "" );
		Assert.isFalse( assembler.allowsIfNotList( ["production", "debug"] ), "" );
	}*/
	
	/*@Test( "Test strict mode" )
	public function testStrictMode( ) : Void
	{
		var assembler : ApplicationAssembler = new ApplicationAssembler();
		assembler.setStrictMode( true );
		assembler.addConditionalProperty( ["production" => true] );
		Assert.methodCallThrows( BuildingException, assembler, assembler.allowsIfList, [["debug"]], "" );
		Assert.methodCallThrows( BuildingException, assembler, assembler.allowsIfNotList, [["debug"]], "" );
	}*/
}