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
	
	@test( "test bulding anonymous object" )
	public function testBuildingAnonymousObject() : Void
	{
		var source : String = '<root><test id="obj" type="Object"><property name="name" value="Francis"/><property name="age" type="Int" value="44"/><property name="height" type="Float" value="1.75"/><property name="isWorking" type="Bool" value="true"/><property name="isSleeping" type="Bool" value="false"/></test></root>';
		var xml : Xml = Xml.parse( source );
		this._build( xml );

		var obj : Dynamic = this._builderFactory.getCoreFactory().locate( "obj" );

		Assert.equals( "Francis", obj.name, "" );
		Assert.equals( 44, obj.age, "" );
		Assert.equals( 1.75, obj.height, "" );
		Assert.isTrue( obj.isWorking, "" );
		Assert.isFalse( obj.isSleeping, "" );
		Assert.equals( 1.75, this._builderFactory.getCoreFactory().locate( "obj.height" ), "" );
	}
}