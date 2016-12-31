package hex.ioc.assembler;

import hex.di.IDependencyInjector;
import hex.di.Injector;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.assembler.ApplicationContext;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextTest
{
	@Test( "Test accessors" )
    public function testAccessors() : Void
    {
		var applicationAssembler 	= new ApplicationAssembler();
		var applicationContext 		: ApplicationContext	= cast applicationAssembler.getApplicationContext( "applicationContext" );
		
		Assert.equals( "applicationContext", applicationContext.getName(), "returned name should be the same passed during instantiation" );
		Assert.isInstanceOf( applicationContext.getInjector(), Injector, "injector returned should be an instance of Injector class" );
		
		var injector = applicationContext.getInjector();
		Assert.equals( injector.getInstance( IDependencyInjector ), injector, "injectors should be the same" );
	}
}