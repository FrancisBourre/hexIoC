package hex.ioc.parser.xml;

import hex.domain.ApplicationDomainDispatcher;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.assembler.IApplicationAssembler;
import hex.ioc.assembler.MockApplicationContextFactory;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.PropertyVO;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.core.BuilderFactory;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ObjectXMLParserTest
{
	private var _contextParser 				: XMLContextParser;
	private var _applicationContext 		: ApplicationContext;
	private var _builderFactory 			: BuilderFactory;
	private var _applicationAssembler 		: IApplicationAssembler;
		
	@setUp
	public function setUp() : Void
	{
		this._applicationAssembler 	= new ApplicationAssembler();
		this._applicationContext 	= this._applicationAssembler.getApplicationContext( "applicationContext" );
		this._builderFactory 		= this._applicationAssembler.getBuilderFactory( this._applicationContext );
	}

	@tearDown
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.getInstance().clear();
		this._applicationAssembler.release();
	}
		
	private function _build( xml : Xml, applicationContext : ApplicationContext = null ) : Void
	{
		this._contextParser = new XMLContextParser();
		this._contextParser.setParserCollection( new XMLParserCollection() );
		this._contextParser.parse( applicationContext != null ? applicationContext : this._applicationContext, this._applicationAssembler, xml );
		this._applicationAssembler.buildEverything();
	}
		
	@test( "" )
	public function testSimpleObjectParsing() : Void
	{
		/*var parser : ObjectXMLParser = new ObjectXMLParser();
		var assembler : IApplicationAssembler = new MockAssembler();
		parser.setApplicationAssembler( assembler );
		var applicationContext : ApplicationContext = assembler.getApplicationContext( "applicationContextName" );
		parser.setContextData( Xml.parse('<root></root>'), applicationContext );
		parser.parse();*/
	}
	
	@test( "test bulding anonymous object" )
	public function testBuildingAnonymousObject() : Void
	{
		/*var source : String = '<root><test id="obj" type="Object"><property name="name" value="Francis"/><property name="age" type="int" value="44"/><property name="height" type="Number" value="1.75"/><property name="isWorking" type="Boolean" value="true"/></test></root>';
		var xml : Xml = Xml.parse( source );
		this._build( xml );

		//asserts
		var obj : Dynamic = this._builderFactory.getCoreFactory().locate( "obj" );

		Assert.equals( "Francis", obj.name, "" );
		Assert.equals( 44, obj.age, "" );
		Assert.equals( 1.75, obj.height, "" );
		Assert.isTrue( obj.isWorking, "" );
		Assert.isFalse( obj.isSleeping, "" );
		Assert.equals( 1.75, this._builderFactory.getCoreFactory().locate( "obj.height" ), "" );*/
	}
}

private class MockAssembler implements IApplicationAssembler
{
	public function new()
	{
		
	}
	
	public function getBuilderFactory( applicationContext : ApplicationContext ) : BuilderFactory 
	{
		return null;
	}
	
	public function release() : Void 
	{
		
	}
	
	public function buildProperty( applicationContext : ApplicationContext, ownerID : String, name : String = null, value : String = null, type : String = null, ref : String = null, method : String = null, staticRef : String = null ) : PropertyVO 
	{
		return null;
	}
	
	public function buildObject( applicationContext : ApplicationContext, ownerID : String, type : String = null, args : Array<Dynamic> = null, factory : String = null, singleton : String = null, mapType : String = null, staticRef : String = null ) : ConstructorVO 
	{
		return null;
	}
	
	public function buildMethodCall( applicationContext : ApplicationContext, ownerID : String, methodCallName:String, args : Array<Dynamic> = null ) : Void 
	{
		return null;
	}
	
	public function buildDomainListener( applicationContext : ApplicationContext, ownerID : String, listenedDomainName : String, args : Array<DomainListenerVOArguments> = null ) : Void 
	{
		return null;
	}
	
	public function registerID( applicationContext : ApplicationContext, ID : String ) : Bool 
	{
		return false;
	}
	
	public function buildEverything() : Void 
	{
		
	}
	
	public function getApplicationContext( applicationContextName : String ) : ApplicationContext 
	{
		return MockApplicationContextFactory.getMockApplicationContext( this, applicationContextName );
	}
}