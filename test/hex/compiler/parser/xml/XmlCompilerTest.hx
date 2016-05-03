package hex.compiler.parser.xml;

import hex.control.command.BasicCommand;
import hex.domain.ApplicationDomainDispatcher;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.core.IContextFactory;
import hex.ioc.core.ICoreFactory;
import hex.ioc.parser.xml.ApplicationXMLParser;
import hex.structures.Point;
import hex.structures.Size;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class XmlCompilerTest
{
	var _contextParser 				: ApplicationXMLParser;
	var _applicationContext 		: AbstractApplicationContext;
	var _contextFactory 			: IContextFactory;
	var _applicationAssembler 		: ApplicationAssembler;

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
		return this._applicationAssembler.getApplicationContext( "applicationContext" ).getCoreFactory();
	}
	/*
	@Test( "test building String" )
	public function testBuildingString() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/testBuildingString.xml" );
		var s : String = this._getCoreFactory().locate( "s" );
		Assert.equals( "hello", s, "" );
	}
	
	@Test( "test building Int" )
	public function testBuildingInt() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/testBuildingInt.xml" );
		var i : String = this._getCoreFactory().locate( "i" );
		Assert.equals( -3, i, "" );
	}
	
	@Test( "test building Bool" )
	public function testBuildingBool() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/testBuildingBool.xml" );
		var b : Bool = this._getCoreFactory().locate( "b" );
		Assert.isTrue( b, "" );
	}
	
	@Test( "test building UInt" )
	public function testBuildingUInt() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/testBuildingUInt.xml" );
		var i : UInt = this._getCoreFactory().locate( "i" );
		Assert.equals( 3, i, "" );
	}
	
	@Test( "test building null" )
	public function testBuildingNull() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/testBuildingNull.xml" );
		var result : Dynamic = this._getCoreFactory().locate( "value" );
		Assert.isNull( result, "" );
	}
	
	@Test( "test building anonymous object" )
	public function testBuildingAnonymousObject() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/anonymousObject.xml" );
		var obj : Dynamic = this._getCoreFactory().locate( "obj" );

		Assert.equals( "Francis", obj.name, "" );
		Assert.equals( 44, obj.age, "" );
		Assert.equals( 1.75, obj.height, "" );
		Assert.isTrue( obj.isWorking, "" );
		Assert.isFalse( obj.isSleeping, "" );
		Assert.equals( 1.75, this._getCoreFactory().locate( "obj.height" ), "" );
	}
	
	@Test( "test building simple instance without arguments" )
	public function testBuildingSimpleInstanceWithoutArguments() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/simpleInstanceWithoutArguments.xml" );

		var command : BasicCommand = this._getCoreFactory().locate( "command" );
		Assert.isInstanceOf( command, BasicCommand, "" );
	}
	
	@Test( "test building simple instance with arguments" )
	public function testBuildingSimpleInstanceWithArguments() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/simpleInstanceWithArguments.xml" );

		var size : Size = this._getCoreFactory().locate( "size" );
		Assert.isInstanceOf( size, Size, "" );
		Assert.equals( 10, size.width, "" );
		Assert.equals( 20, size.height, "" );
	}
	*/
	@Test( "test building multiple instances with arguments" )
	public function testBuildingMultipleInstancesWithArguments() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/multipleInstancesWithArguments.xml" );

		var size : Size = this._getCoreFactory().locate( "size" );
		Assert.isInstanceOf( size, Size, "" );
		Assert.equals( 15, size.width, "" );
		Assert.equals( 25, size.height, "" );

		var position : Point = this._getCoreFactory().locate( "position" );
		Assert.isInstanceOf( position, Point, "" );
		Assert.equals( 35, position.x, "" );
		Assert.equals( 45, position.y, "" );
	}
	/*
	@Test( "test building single instance with references" )
	public function testBuildingSingleInstanceWithReferences() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/singleInstanceWithReferences.xml" );
		
		var x : Int = this._getCoreFactory().locate( "x" );
		Assert.equals( 1, x, "" );
		
		var y : Int = this._getCoreFactory().locate( "y" );
		Assert.equals( 2, y, "" );

		var position : Point = this._getCoreFactory().locate( "position" );
		Assert.isInstanceOf( position, Point, "" );
		Assert.equals( 1, position.x, "" );
		Assert.equals( 2, position.y, "" );
	}*/
}