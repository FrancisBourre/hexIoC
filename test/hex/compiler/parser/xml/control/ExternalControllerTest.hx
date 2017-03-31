package hex.compiler.parser.xml.control;

import hex.core.IApplicationAssembler;
import hex.core.ICoreFactory;
import hex.domain.ApplicationDomainDispatcher;
import hex.ioc.assembler.ApplicationContext;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ExternalControllerTest 
{
	var _applicationAssembler : IApplicationAssembler;

	@Before
	public function setUp() : Void
	{

	}

	@After
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.getInstance().clear();
		this._applicationAssembler.release();
	}
	
	function _getCoreFactory() : ICoreFactory
	{
		return this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory();
	}
	
	function _locate( key : String ) : Dynamic
	{
		return this._getCoreFactory().locate( key );
	}
	
	@Test( "test command execution in the context with controller injection" )
	public function testCommandExecutionInTheContextWithControllerInjection() : Void
	{
		this._applicationAssembler = XmlCompiler.compile( "context/xml/externalControllerInjection.xml" );
		
		this._locate( 'sender' ).sayHelloworldWithControllerInjection();
		Assert.equals( 'hello world', this._locate( 'receiver' ).message );
	}
	
	@Test( "test command execution in the context with function injection" )
	public function testCommandExecutionInTheContextWithFunctionInjection() : Void
	{
		this._applicationAssembler = XmlCompiler.compile( "context/xml/externalControllerMethodInjection.xml" );
		
		this._locate( 'sender' ).sayHelloworldWithFunctionInjection();
		Assert.equals( 'hello world', this._locate( 'receiver' ).message );
	}
}