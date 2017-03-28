package hex.compiler.parser.xml.assembler;

import hex.core.IApplicationAssembler;
import hex.core.ICoreFactory;
import hex.domain.ApplicationDomainDispatcher;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.parser.xml.assembler.mock.AnotherMockStateCommand;
import hex.ioc.parser.xml.assembler.mock.MockBuildContextExitCommand;
import hex.ioc.parser.xml.assembler.mock.MockStateCommand;
import hex.runtime.ApplicationAssembler;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class BuildTwoContextsWithStateTransitionsTest
{
	public static var applicationAssembler 	: IApplicationAssembler;
	
		
	@Before
	public function setUp() : Void
	{
		applicationAssembler 	= new ApplicationAssembler();
	}

	@After
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.getInstance().clear();
		applicationAssembler.release();
	}
		
	function _getCoreFactory() : ICoreFactory
	{
		return applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory();
	}
	
	@Test( "test with compile time and runtime mixed" )
	public function testWithCompileAndRuntimeMixed() : Void
	{
		MockStateCommand.callCount = 0;
		AnotherMockStateCommand.callCount = 0;
		MockBuildContextExitCommand.callCount = 0;
		
		XmlCompiler.compileWithAssembler( applicationAssembler, "context/testBuildingStateTransitionsFirstPass.xml" );
		
		var context = applicationAssembler.getApplicationContext( 'applicationContext', ApplicationContext );
		Assert.equals( context.state.ASSEMBLING_END, context.getCurrentState() );
		
		//called one more time, because command registered in the 1st DSL pass is not setted to fire-once
		Assert.equals( 11, MockStateCommand.callCount );
		
		//
		Assert.equals( 11, AnotherMockStateCommand.callCount );
		Assert.equals( 1, MockBuildContextExitCommand.callCount );
	}
}