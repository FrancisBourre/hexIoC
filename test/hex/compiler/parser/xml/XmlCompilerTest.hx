package hex.compiler.parser.xml;

import hex.collection.HashMap;
import hex.config.stateful.ServiceLocator;
import hex.control.command.BasicCommand;
import hex.di.Injector;
import hex.domain.ApplicationDomainDispatcher;
import hex.event.Dispatcher;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.core.IContextFactory;
import hex.ioc.core.ICoreFactory;
import hex.ioc.di.MappingConfiguration;
import hex.ioc.parser.xml.ApplicationXMLParser;
import hex.ioc.parser.xml.mock.AnotherMockAmazonService;
import hex.ioc.parser.xml.mock.ClassWithConstantConstantArgument;
import hex.ioc.parser.xml.mock.IMockAmazonService;
import hex.ioc.parser.xml.mock.IMockFacebookService;
import hex.ioc.parser.xml.mock.MockAmazonService;
import hex.ioc.parser.xml.mock.MockCaller;
import hex.ioc.parser.xml.mock.MockChatModule;
import hex.ioc.parser.xml.mock.MockFacebookService;
import hex.ioc.parser.xml.mock.MockFruitVO;
import hex.ioc.parser.xml.mock.MockRectangle;
import hex.ioc.parser.xml.mock.MockServiceProvider;
import hex.ioc.parser.xml.mock.MockStubStatefulService;
import hex.ioc.parser.xml.mock.MockTranslationModule;
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
		var i : Int = this._getCoreFactory().locate( "i" );
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
	}
	
	@Test( "test building multiple instances with references" )
	public function testAssignInstancePropertyWithReference() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/instancePropertyWithReference.xml" );
		
		var width : Int = this._getCoreFactory().locate( "width" );
		Assert.equals( 10, width, "" );
		
		var height : Int = this._getCoreFactory().locate( "height" );
		Assert.equals( 20, height, "" );
		
		var size : Point = this._getCoreFactory().locate( "size" );
		Assert.isInstanceOf( size, Point, "" );
		Assert.equals( width, size.x, "" );
		Assert.equals( height, size.y, "" );
		
		var rect : MockRectangle = this._getCoreFactory().locate( "rect" );
		Assert.equals( width, rect.size.x, "" );
		Assert.equals( height, rect.size.y, "" );
	}
	
	@Test( "test building multiple instances with references" )
	public function testBuildingMultipleInstancesWithReferences() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/multipleInstancesWithReferences.xml" );

		var rectSize : Point = this._getCoreFactory().locate( "rectSize" );
		Assert.isInstanceOf( rectSize, Point, "" );
		Assert.equals( 30, rectSize.x, "" );
		Assert.equals( 40, rectSize.y, "" );

		var rectPosition : Point = this._getCoreFactory().locate( "rectPosition" );
		Assert.isInstanceOf( rectPosition, Point, "" );
		Assert.equals( 10, rectPosition.x, "" );
		Assert.equals( 20, rectPosition.y, "" );

		var rect : MockRectangle = this._getCoreFactory().locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle, "" );
		Assert.equals( 10, rect.x, "" );
		Assert.equals( 20, rect.y, "" );
		Assert.equals( 30, rect.size.x, "" );
		Assert.equals( 40, rect.size.y, "" );
	}
	
	@Test( "test simple method call" )
	public function testSimpleMethodCall() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/simpleMethodCall.xml" );

		var caller : MockCaller = this._getCoreFactory().locate( "caller" );
		Assert.isInstanceOf( caller, MockCaller, "" );
		Assert.deepEquals( [ "hello", "world" ], MockCaller.passedArguments, "" );
	}
	
	@Test( "test building multiple instances with method calls" )
	public function testBuildingMultipleInstancesWithMethodCall() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/multipleInstancesWithMethodCall.xml" );

		var rectSize : Point = this._getCoreFactory().locate( "rectSize" );
		Assert.isInstanceOf( rectSize, Point, "" );
		Assert.equals( 30, rectSize.x, "" );
		Assert.equals( 40, rectSize.y, "" );

		var rectPosition : Point = this._getCoreFactory().locate( "rectPosition" );
		Assert.isInstanceOf( rectPosition, Point, "" );
		Assert.equals( 10, rectPosition.x, "" );
		Assert.equals( 20, rectPosition.y, "" );


		var rect : MockRectangle = this._getCoreFactory().locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle, "" );
		Assert.equals( 10, rect.x, "" );
		Assert.equals( 20, rect.y, "" );
		Assert.equals( 30, rect.width, "" );
		Assert.equals( 40, rect.height, "" );

		var anotherRect : MockRectangle = this._getCoreFactory().locate( "anotherRect" );
		Assert.isInstanceOf( anotherRect, MockRectangle, "" );
		Assert.equals( 0, anotherRect.x, "" );
		Assert.equals( 0, anotherRect.y, "" );
		Assert.equals( 0, anotherRect.width, "" );
		Assert.equals( 0, anotherRect.height, "" );
	}
	
	@Test( "test building instance with singleton method" )
	public function testBuildingInstanceWithSingletonMethod() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/instanceWithSingletonMethod.xml" );

		var service : MockServiceProvider = this._getCoreFactory().locate( "service" );
		Assert.isInstanceOf( service, MockServiceProvider, "" );
		Assert.equals( "http://localhost/amfphp/gateway.php", MockServiceProvider.getInstance().getGateway(), "" );
	}
	
	@Test( "test building instance with factory static method" )
	public function testBuildingInstanceWithFactoryStaticMethod() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/instanceWithFactoryStaticMethod.xml" );

		var rect : MockRectangle = this._getCoreFactory().locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle, "" );
		Assert.equals( 10, rect.x, "" );
		Assert.equals( 20, rect.y, "" );
		Assert.equals( 30, rect.width, "" );
		Assert.equals( 40, rect.height, "" );
	}
	
	@Test( "test building instance with factory singleton method" )
	public function testFactoryWithFactorySingletonMethod() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/instanceWithFactorySingletonMethod.xml" );

		var point : Point = this._getCoreFactory().locate( "point" );
		Assert.isInstanceOf( point, Point, "" );
		Assert.equals( 10, point.x, "" );
		Assert.equals( 20, point.y, "" );
	}
	
	/*@Test( "test 'inject-into' attribute" )
	public function testInjectIntoAttribute() : Void
	{
		var injector = this._applicationContext.getBasicInjector();
		injector.mapToValue( String, 'hola mundo' );

		this.build(  XmlReader.readXmlFile( "context/injectIntoAttribute.xml" ) );

		var instance : MockClassWithInjectedProperty = this._builderFactory.getCoreFactory().locate( "instance" );
		Assert.isInstanceOf( instance, MockClassWithInjectedProperty, "" );
		Assert.equals( "hola mundo", instance.property, "" );
	}*/
	
	@Test( "test building XML with parser class" )
	public function testBuildingXMLWithParserClass() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/xmlWithParserClass.xml" );

		var fruits : Array<MockFruitVO> = this._getCoreFactory().locate( "fruits" );
		Assert.equals( 3, fruits.length, "" );

		var orange : MockFruitVO = fruits[0];
		var apple : MockFruitVO = fruits[1];
		var banana : MockFruitVO = fruits[2];

		Assert.equals( "orange", orange.toString(), "" );
		Assert.equals( "apple", apple.toString(), "" );
		Assert.equals( "banana", banana.toString(), "" );
	}
	
	@Test( "test building Arrays" )
	public function testBuildingArrays() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/arrayFilledWithReferences.xml" );
		
		var text : Array<String> = this._getCoreFactory().locate( "text" );
		Assert.equals( 2, text.length, "" );
		Assert.equals( "hello", text[ 0 ], "" );
		Assert.equals( "world", text[ 1 ], "" );
		
		var empty : Array<String> = this._getCoreFactory().locate( "empty" );
		Assert.equals( 0, empty.length, "" );

		var fruits : Array<MockFruitVO> = this._getCoreFactory().locate( "fruits" );
		Assert.equals( 3, fruits.length, "" );

		var orange 	: MockFruitVO = fruits[0];
		var apple 	: MockFruitVO = fruits[1];
		var banana 	: MockFruitVO = fruits[2];

		Assert.equals( "orange", orange.toString(), "" );
		Assert.equals( "apple", apple.toString(), "" );
		Assert.equals( "banana", banana.toString(), "" );
	}
	
	@Test( "test building Map filled with references" )
	public function testBuildingMapFilledWithReferences() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/hashmapFilledWithReferences.xml" );

		var fruits : HashMap<Dynamic, MockFruitVO> = this._getCoreFactory().locate( "fruits" );
		Assert.isNotNull( fruits, "" );

		var stubKey : Point = this._getCoreFactory().locate( "stubKey" );
		Assert.isNotNull( stubKey, "" );

		var orange 	: MockFruitVO = fruits.get( '0' );
		var apple 	: MockFruitVO = fruits.get( 1 );
		var banana 	: MockFruitVO = fruits.get( stubKey );

		Assert.equals( "orange", orange.toString(), "" );
		Assert.equals( "apple", apple.toString(), "" );
		Assert.equals( "banana", banana.toString(), "" );
	}
	
	@Test( "test building Map with class reference" )
	public function testBuildingMapWithClassReference() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/hashmapWithClassReference.xml" );

		var map : HashMap<Class<IMockAmazonService>, Class<MockAmazonService>> = this._getCoreFactory().locate( "map" );
		Assert.isNotNull( map, "" );
		
		var amazonServiceClass : Class<MockAmazonService> = map.get( IMockAmazonService );
		Assert.equals( IMockAmazonService, map.getKeys()[ 0 ], "" );
		Assert.equals( MockAmazonService, amazonServiceClass, "" );
	}
	
	@Test( "test building two modules listening each other" )
	public function testBuildingTwoModulesListeningEachOther() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/twoModulesListeningEachOther.xml" );

		var chat : MockChatModule = this._getCoreFactory().locate( "chat" );
		Assert.isNotNull( chat, "" );
		Assert.isNull( chat.translatedMessage, "" );

		var translation : MockTranslationModule = this._getCoreFactory().locate( "translation" );
		Assert.isNotNull( translation, "" );

		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "Hello", chat.translatedMessage, "" );
	}
	
	@Test( "test building class reference" )
	public function testBuildingClassReference() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/classReference.xml" );

		var rectangleClass : Class<MockRectangle> = this._getCoreFactory().locate( "RectangleClass" );
		Assert.isInstanceOf( rectangleClass, Class, "" );
		Assert.isInstanceOf( Type.createInstance( rectangleClass, [] ), MockRectangle, "" );

		var classContainer = this._getCoreFactory().locate( "classContainer" );

		var anotherRectangleClass : Class<MockRectangle> = classContainer.AnotherRectangleClass;
		Assert.isInstanceOf( anotherRectangleClass, Class, "" );
		Assert.isInstanceOf( Type.createInstance( anotherRectangleClass, [] ), MockRectangle, "" );

		Assert.equals( rectangleClass, anotherRectangleClass, "" );

		var anotherRectangleClassRef : Class<MockRectangle> = this._getCoreFactory().locate( "classContainer.AnotherRectangleClass" );
		Assert.isInstanceOf( anotherRectangleClassRef, Class, "" );
		Assert.equals( anotherRectangleClass, anotherRectangleClassRef, "" );
	}
	
	@Test( "test building mapping configuration" )
	public function testBuildingMappingConfiguration() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/mappingConfiguration.xml" );

		var config : MappingConfiguration = this._getCoreFactory().locate( "config" );
		Assert.isInstanceOf( config, MappingConfiguration, "" );

		var injector = new Injector();
		config.configure( injector, new Dispatcher(), null );

		Assert.isInstanceOf( injector.getInstance( IMockAmazonService ), MockAmazonService, "" );
		Assert.isInstanceOf( injector.getInstance( IMockFacebookService ), MockFacebookService, "" );
		Assert.equals( this._getCoreFactory().locate( "facebookService" ), injector.getInstance( IMockFacebookService ), "" );
	}
	
	@Test( "test building mapping configuration with map names" )
	public function testBuildingMappingConfigurationWithMapNames() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/mappingConfigurationWithMapNames.xml" );

		var config : MappingConfiguration = this._getCoreFactory().locate( "config" );
		Assert.isInstanceOf( config, MappingConfiguration, "" );

		var injector = new Injector();
		config.configure( injector, new Dispatcher(), null );

		Assert.isInstanceOf( injector.getInstance( IMockAmazonService, "amazon0" ),  MockAmazonService, "" );
		Assert.isInstanceOf( injector.getInstance( IMockAmazonService, "amazon1" ), AnotherMockAmazonService, "" );
	}
	
	@Test( "test building mapping configuration with singleton" )
	public function testBuildingMappingConfigurationWithSingleton() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/mappingConfigurationWithSingleton.xml" );

		var config = this._getCoreFactory().locate( "config" );
		Assert.isInstanceOf( config, MappingConfiguration, "" );

		var injector = new Injector();
		config.configure( injector, new Dispatcher(), null );

		var amazon0 = injector.getInstance( IMockAmazonService, "amazon0" );
		Assert.isInstanceOf( amazon0,  MockAmazonService, "" );
		
		var copyOfAmazon0 = injector.getInstance( IMockAmazonService, "amazon0" );
		Assert.isInstanceOf( copyOfAmazon0,  MockAmazonService, "" );
		Assert.equals( amazon0, copyOfAmazon0, "" );
		
		var amazon1 = injector.getInstance( IMockAmazonService, "amazon1" );
		Assert.isInstanceOf( amazon1, AnotherMockAmazonService, "" );
		
		var copyOfAmazon1 = injector.getInstance( IMockAmazonService, "amazon1" );
		Assert.isInstanceOf( copyOfAmazon1,  AnotherMockAmazonService, "" );
		Assert.notEquals( amazon1, copyOfAmazon1, "" );
	}
	
	@Test( "test building serviceLocator" )
	public function testBuildingServiceLocator() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/serviceLocator.xml" );

		var serviceLocator : ServiceLocator = this._getCoreFactory().locate( "serviceLocator" );
		Assert.isInstanceOf( serviceLocator, ServiceLocator, "" );

		var amazonService : IMockAmazonService = serviceLocator.getService( IMockAmazonService );
		var facebookService : IMockFacebookService = serviceLocator.getService( IMockFacebookService );
		Assert.isInstanceOf( amazonService, MockAmazonService, "" );
		Assert.isInstanceOf( facebookService, MockFacebookService, "" );

		var injector = new Injector();
		serviceLocator.configure( injector, new Dispatcher(), null );

		Assert.isInstanceOf( injector.getInstance( IMockAmazonService ), MockAmazonService, "" );
		Assert.isInstanceOf( injector.getInstance( IMockFacebookService ), MockFacebookService, "" );
		Assert.equals( facebookService, injector.getInstance( IMockFacebookService ), "" );
	}
	
	@Test( "test building serviceLocator with map names" )
	public function testBuildingServiceLocatorWithMapNames() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/serviceLocatorWithMapNames.xml" );

		var serviceLocator : ServiceLocator = this._getCoreFactory().locate( "serviceLocator" );
		Assert.isInstanceOf( serviceLocator, ServiceLocator, "" );

		var amazonService0 : IMockAmazonService = serviceLocator.getService( IMockAmazonService, "amazon0" );
		var amazonService1 : IMockAmazonService = serviceLocator.getService( IMockAmazonService, "amazon1" );
		Assert.isNotNull( amazonService0, "" );
		Assert.isNotNull( amazonService1, "" );

		var injector = new Injector();
		serviceLocator.configure( injector, new Dispatcher(), null );

		Assert.isInstanceOf( injector.getInstance( IMockAmazonService, "amazon0" ),  MockAmazonService, "" );
		Assert.isInstanceOf( injector.getInstance( IMockAmazonService, "amazon1" ), AnotherMockAmazonService, "" );
	}
	
	@Test( "test static-ref" )
	public function testStaticRef() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile(  "context/staticRef.xml" );

		var note : String = this._getCoreFactory().locate( "constant" );
		Assert.isNotNull( note, "" );
		Assert.equals( note, MockStubStatefulService.INT_VO_UPDATE, "" );
	}
	
	@Test( "test static-ref property" )
	public function testStaticProperty() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile(  "context/staticRefProperty.xml" );

		var object : Dynamic = this._getCoreFactory().locate( "object" );
		Assert.isNotNull( object, "" );
		Assert.equals( object.property, MockStubStatefulService.INT_VO_UPDATE, "" );
	}
	
	@Test( "test static-ref argument" )
	public function testStaticArgument() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile(  "context/staticRefArgument.xml" );

		var instance : ClassWithConstantConstantArgument = this._getCoreFactory().locate( "instance" );
		Assert.isNotNull( instance, "" );
		Assert.equals( instance.constant, MockStubStatefulService.INT_VO_UPDATE, "" );
	}
}