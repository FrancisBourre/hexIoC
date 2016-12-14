package hex.compiler.parser.flow;

import hex.compiler.parser.flow.FlowCompiler;
import hex.domain.ApplicationDomainDispatcher;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.core.IContextFactory;
import hex.ioc.core.ICoreFactory;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class FlowCompilerTest 
{
	var _contextFactory 			: IContextFactory;
	var _applicationAssembler 		: ApplicationAssembler;
	
	static var applicationAssembler : ApplicationAssembler;

	@Before
	public function setUp() : Void
	{

	}

	@After
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.getInstance().clear();
		//this._applicationAssembler.release();
	}
	
	function _getCoreFactory() : ICoreFactory
	{
		return this._applicationAssembler.getApplicationContext( "applicationContext" ).getCoreFactory();
	}
	
	@Ignore( "test building String" )
	public function testBuildingString() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/testBuildingString.flow" );
		//var s : String = this._getCoreFactory().locate( "s" );
		//Assert.equals( "hello", s, "" );
	}
}