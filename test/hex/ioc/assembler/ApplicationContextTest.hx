package hex.ioc.assembler;

import hex.di.IBasicInjector;
import hex.inject.Injector;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.assembler.ApplicationContext;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextTest
{
	@test( "Test accessors" )
    public function testAccessors() : Void
    {
		var applicationAssembler 	: ApplicationAssembler	= new ApplicationAssembler();
		var applicationContext 		: ApplicationContext	= applicationAssembler.getApplicationContext( "applicationContext" );
		
		Assert.equals( "applicationContext", applicationContext.getName(), "returned name should be the same passed during instantiation" );
		Assert.isInstanceOf( applicationContext.getBasicInjector(), Injector, "injector returned should be an instance of Injector class" );
		
		var injector : IBasicInjector = applicationContext.getBasicInjector();
		Assert.equals( injector.getInstance( IBasicInjector ), injector, "injectors should be the same" );
	}
	
	@test( "Test children" )
    public function testChildren() : Void
    {
		var applicationAssembler 	: ApplicationAssembler	= new ApplicationAssembler();
		var applicationContext 		: ApplicationContext	= applicationAssembler.getApplicationContext( "applicationContext" );
		var anotherContext 			: ApplicationContext	= applicationAssembler.getApplicationContext( "anotherContext" );
		
		Assert.notEquals( applicationContext, anotherContext, "application contexts should be different" );
		Assert.isTrue( applicationContext.addChild( anotherContext ), "'addChild' should return true when adding a context child for the first time" );
		Assert.isFalse( applicationContext.addChild( anotherContext ), "'addChild' should return false when adding a context child for the first time" );
		Assert.equals( anotherContext, applicationContext.anotherContext, "application context should be the same" );
	}
}