package hex.ioc.parser.xml;

import hex.di.Injector;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.core.IContextFactory;
import hex.ioc.di.MappingConfiguration;
import hex.ioc.parser.preprocess.Preprocessor;
import haxe.Timer;
import hex.collection.HashMap;
import hex.config.stateful.ServiceLocator;
import hex.domain.ApplicationDomainDispatcher;
import hex.event.Dispatcher;
import hex.event.EventProxy;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.parser.xml.mock.AnotherMockAmazonService;
import hex.ioc.parser.xml.mock.AnotherMockModuleWithServiceCallback;
import hex.ioc.parser.xml.mock.ClassWithConstantConstantArgument;
import hex.ioc.parser.xml.mock.IMockAmazonService;
import hex.ioc.parser.xml.mock.IMockDividerHelper;
import hex.ioc.parser.xml.mock.IMockFacebookService;
import hex.ioc.parser.xml.mock.IMockMappedModule;
import hex.ioc.parser.xml.mock.IMockStubStatefulService;
import hex.ioc.parser.xml.mock.MockAmazonService;
import hex.ioc.parser.xml.mock.MockBooleanVO;
import hex.ioc.parser.xml.mock.MockChatModule;
import hex.ioc.parser.xml.mock.MockClassWithInjectedProperty;
import hex.ioc.parser.xml.mock.MockFacebookService;
import hex.ioc.parser.xml.mock.MockFruitVO;
import hex.ioc.parser.xml.mock.MockIntVO;
import hex.ioc.parser.xml.mock.MockMappedModule;
import hex.ioc.parser.xml.mock.MockMessageParserModule;
import hex.ioc.parser.xml.mock.MockModuleWithServiceCallback;
import hex.ioc.parser.xml.mock.MockObjectWithRegtangleProperty;
import hex.ioc.parser.xml.mock.MockReceiverModule;
import hex.ioc.parser.xml.mock.MockRectangle;
import hex.ioc.parser.xml.mock.MockSenderModule;
import hex.ioc.parser.xml.mock.MockServiceProvider;
import hex.ioc.parser.xml.mock.MockTranslationModule;
import hex.structures.PointFactory;
import hex.structures.Point;
import hex.structures.Size;
import hex.unittest.assertion.Assert;
import hex.unittest.runner.MethodRunner;
import hex.ioc.parser.xml.mock.MockStubStatefulService;


/**
 * ...
 * @author Francis Bourre
 */
class ObjectXMLParserTest
{
	var _contextParser 				: ApplicationXMLParser;
	var _applicationContext 		: AbstractApplicationContext;
	var _builderFactory 			: IContextFactory;
	var _applicationAssembler 		: ApplicationAssembler;
		
	@Before
	public function setUp() : Void
	{
		this._applicationAssembler 	= new ApplicationAssembler();
		this._applicationContext 	= this._applicationAssembler.getApplicationContext( "applicationContext" );
		this._builderFactory 		= this._applicationAssembler.getContextFactory( this._applicationContext );
		this._builderFactory.getCoreFactory().addProxyFactoryMethod( "hex.structures.Point", PointFactory, PointFactory.build );
	}

	@After
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.getInstance().clear();
		this._applicationAssembler.release();
	}
		
	function _build( xml : Xml, applicationContext : AbstractApplicationContext = null ) : Void
	{
		this._contextParser = new ApplicationXMLParser();
		//this._contextParser.parse( applicationContext != null ? applicationContext : this._applicationContext, this._applicationAssembler, xml );
		this._contextParser.parse( this._applicationAssembler, xml );
		this._applicationAssembler.buildEverything();
	}

	function build( xml : String ) : Void
	{
		this._contextParser = new ApplicationXMLParser();
		this._contextParser.parse( this._applicationAssembler, Xml.parse( xml ) );
		this._applicationAssembler.buildEverything();
	}
	
	@Test( "test building String" )
	public function testBuildingString() : Void
	{
		this.build( XmlReader.readXmlFile( "context/testBuildingString.xml" ) );
		var s : String = this._builderFactory.getCoreFactory().locate( "s" );
		Assert.equals( "hello", s, "" );
	}
	
	@Test( "test building Int" )
	public function testBuildingInt() : Void
	{
		this.build( XmlReader.readXmlFile( "context/testBuildingInt.xml" ) );
		var i : Int = this._builderFactory.getCoreFactory().locate( "i" );
		Assert.equals( -3, i, "" );
	}
	
	@Test( "test building Bool" )
	public function testBuildingBool() : Void
	{
		this.build( XmlReader.readXmlFile( "context/testBuildingBool.xml" ) );
		var b : Bool = this._builderFactory.getCoreFactory().locate( "b" );
		Assert.isTrue( b, "" );
	}
	
	@Test( "test building UInt" )
	public function testBuildingUInt() : Void
	{
		this.build( XmlReader.readXmlFile( "context/testBuildingUInt.xml" ) );
		var i : UInt = this._builderFactory.getCoreFactory().locate( "i" );
		Assert.equals( 3, i, "" );
	}
	
	@Test( "test building null" )
	public function testBuildingNull() : Void
	{
		this.build( XmlReader.readXmlFile( "context/testBuildingNull.xml" ) );
		var result : Dynamic = this._builderFactory.getCoreFactory().locate( "value" );
		Assert.isNull( result, "" );
	}
	
	@Test( "test building anonymous object" )
	public function testBuildingAnonymousObject() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/anonymousObject.xml" ) );
		var obj : Dynamic = this._builderFactory.getCoreFactory().locate( "obj" );

		Assert.equals( "Francis", obj.name, "" );
		Assert.equals( 44, obj.age, "" );
		Assert.equals( 1.75, obj.height, "" );
		Assert.isTrue( obj.isWorking, "" );
		Assert.isFalse( obj.isSleeping, "" );
		Assert.equals( 1.75, this._builderFactory.getCoreFactory().locate( "obj.height" ), "" );
	}
	
	@Test( "test building simple instance with arguments" )
	public function testBuildingSimpleInstanceWithArguments() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/simpleInstanceWithArguments.xml" ) );

		var size : Size = this._builderFactory.getCoreFactory().locate( "size" );
		Assert.isInstanceOf( size, Size, "" );
		Assert.equals( 10, size.width, "" );
		Assert.equals( 20, size.height, "" );
	}
	
	@Test( "test building multiple instances with arguments" )
	public function testBuildingMultipleInstancesWithArguments() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/multipleInstancesWithArguments.xml" ) );

		var size : Size = this._builderFactory.getCoreFactory().locate( "size" );
		Assert.isInstanceOf( size, Size, "" );
		Assert.equals( 15, size.width, "" );
		Assert.equals( 25, size.height, "" );

		var position : Point = this._builderFactory.getCoreFactory().locate( "position" );
		//Assert.isInstanceOf( position, Point, "" );
		Assert.equals( 35, position.x, "" );
		Assert.equals( 45, position.y, "" );
	}
	
	@Test( "test building single instance with primitives references" )
	public function testBuildingSingleInstanceWithPrimitivesReferences() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/singleInstanceWithPrimReferences.xml" ) );
		
		var x : Int = this._builderFactory.getCoreFactory().locate( "x" );
		Assert.equals( 1, x, "" );
		
		var y : Int = this._builderFactory.getCoreFactory().locate( "y" );
		Assert.equals( 2, y, "" );

		var position : Point = this._builderFactory.getCoreFactory().locate( "position" );
		//Assert.isInstanceOf( position, Point, "" );
		Assert.equals( 1, position.x, "" );
		Assert.equals( 2, position.y, "" );
	}
	
	@Test( "test building single instance with object references" )
	public function testBuildingSingleInstanceWithObjectReferences() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/singleInstanceWithObjectReferences.xml" ) );
		
		var chat : MockChatModule = this._builderFactory.getCoreFactory().locate( "chat" );
		Assert.isInstanceOf( chat, MockChatModule, "" );
		
		var receiver : MockReceiverModule = this._builderFactory.getCoreFactory().locate( "receiver" );
		Assert.isInstanceOf( receiver, MockReceiverModule, "" );
		
		var proxyChat : EventProxy = this._builderFactory.getCoreFactory().locate( "proxyChat" );
		Assert.isInstanceOf( proxyChat, EventProxy, "" );
		
		var proxyReceiver : EventProxy = this._builderFactory.getCoreFactory().locate( "proxyReceiver" );
		Assert.isInstanceOf( proxyReceiver, EventProxy, "" );

		Assert.equals( chat, proxyChat.scope, "" );
		Assert.equals( Reflect.field( chat, "onTranslation" ), proxyChat.callback, "" );
		
		
		Assert.equals( receiver, proxyReceiver.scope, "" );
		Assert.equals( Reflect.field( receiver, "onMessage" ), proxyReceiver.callback, "" );
	}
	
	@Test( "test building multiple instances with references" )
	public function testAssignInstancePropertyWithReference() : Void
	{
		this.build( XmlReader.readXmlFile( "context/instancePropertyWithReference.xml" ) );
		
		var width : Int = this._builderFactory.getCoreFactory().locate( "width" );
		Assert.equals( 10, width, "" );
		
		var height : Int = this._builderFactory.getCoreFactory().locate( "height" );
		Assert.equals( 20, height, "" );
		
		var size : Point = this._builderFactory.getCoreFactory().locate( "size" );
		//Assert.isInstanceOf( size, Point, "" );
		Assert.equals( width, size.x, "" );
		Assert.equals( height, size.y, "" );
		
		var rect : MockRectangle = this._builderFactory.getCoreFactory().locate( "rect" );
		Assert.equals( width, rect.size.x, "" );
		Assert.equals( height, rect.size.y, "" );
	}
	
	@Test( "test building multiple instances with references" )
	public function testBuildingMultipleInstancesWithReferences() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/multipleInstancesWithReferences.xml" ) );

		var rectSize : Point = this._builderFactory.getCoreFactory().locate( "rectSize" );
		//Assert.isInstanceOf( rectSize, Point, "" );
		Assert.equals( 30, rectSize.x, "" );
		Assert.equals( 40, rectSize.y, "" );

		var rectPosition : Point = this._builderFactory.getCoreFactory().locate( "rectPosition" );
		//Assert.isInstanceOf( rectPosition, Point, "" );
		Assert.equals( 10, rectPosition.x, "" );
		Assert.equals( 20, rectPosition.y, "" );


		var rect : MockRectangle = this._builderFactory.getCoreFactory().locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle, "" );
		Assert.equals( 10, rect.x, "" );
		Assert.equals( 20, rect.y, "" );
		Assert.equals( 30, rect.size.x, "" );
		Assert.equals( 40, rect.size.y, "" );
	}
	
	@Test( "test building multiple instances with method calls" )
	public function testBuildingMultipleInstancesWithMethodCall() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/multipleInstancesWithMethodCall.xml" ) );

		var rectSize : Point = this._builderFactory.getCoreFactory().locate( "rectSize" );
		//Assert.isInstanceOf( rectSize, Point, "" );
		Assert.equals( 30, rectSize.x, "" );
		Assert.equals( 40, rectSize.y, "" );

		var rectPosition : Point = this._builderFactory.getCoreFactory().locate( "rectPosition" );
		//Assert.isInstanceOf( rectPosition, Point, "" );
		Assert.equals( 10, rectPosition.x, "" );
		Assert.equals( 20, rectPosition.y, "" );


		var rect : MockRectangle = this._builderFactory.getCoreFactory().locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle, "" );
		Assert.equals( 10, rect.x, "" );
		Assert.equals( 20, rect.y, "" );
		Assert.equals( 30, rect.width, "" );
		Assert.equals( 40, rect.height, "" );

		var anotherRect : MockRectangle = this._builderFactory.getCoreFactory().locate( "anotherRect" );
		Assert.isInstanceOf( anotherRect, MockRectangle, "" );
		Assert.equals( 0, anotherRect.x, "" );
		Assert.equals( 0, anotherRect.y, "" );
		Assert.equals( 0, anotherRect.width, "" );
		Assert.equals( 0, anotherRect.height, "" );
	}
	
	@Test( "test building instance with singleton method" )
	public function testBuildingInstanceWithSingletonMethod() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/instanceWithSingletonMethod.xml" ) );

		var service : MockServiceProvider = this._builderFactory.getCoreFactory().locate( "service" );
		Assert.isInstanceOf( service, MockServiceProvider, "" );
		Assert.equals( "http://localhost/amfphp/gateway.php", MockServiceProvider.getInstance().getGateway(), "" );
	}
	
	@Test( "test building instance with factory static method" )
	public function testBuildingInstanceWithFactoryStaticMethod() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/instanceWithFactoryStaticMethod.xml" ) );

		var rect : MockRectangle = this._builderFactory.getCoreFactory().locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle, "" );
		Assert.equals( 10, rect.x, "" );
		Assert.equals( 20, rect.y, "" );
		Assert.equals( 30, rect.width, "" );
		Assert.equals( 40, rect.height, "" );
	}
	
	@Test( "test building instance with factory singleton method" )
	public function testFactoryWithFactorySingletonMethod() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/instanceWithFactorySingletonMethod.xml" ) );

		var point : Point = this._builderFactory.getCoreFactory().locate( "point" );
		//Assert.isInstanceOf( point, Point, "" );
		Assert.equals( 10, point.x, "" );
		Assert.equals( 20, point.y, "" );
	}

	@Test( "test 'inject-into' attribute" )
	public function testInjectIntoAttribute() : Void
	{
		var injector = this._applicationContext.getInjector();
		injector.mapToValue( String, 'hola mundo' );

		this.build(  XmlReader.readXmlFile( "context/injectIntoAttribute.xml" ) );

		var instance : MockClassWithInjectedProperty = this._builderFactory.getCoreFactory().locate( "instance" );
		Assert.isInstanceOf( instance, MockClassWithInjectedProperty, "" );
		Assert.equals( "hola mundo", instance.property, "" );
	}
	
	@Test( "test building XML with parser class" )
	public function testBuildingXMLWithParserClass() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/xmlWithParserClass.xml" ) );

		var fruits : Array<MockFruitVO> = this._builderFactory.getCoreFactory().locate( "fruits" );
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
		this.build(  XmlReader.readXmlFile( "context/arrayFilledWithReferences.xml" ) );
		
		var text : Array<String> = this._builderFactory.getCoreFactory().locate( "text" );
		Assert.equals( 2, text.length, "" );
		Assert.equals( "hello", text[ 0 ], "" );
		Assert.equals( "world", text[ 1 ], "" );
		
		var empty : Array<String> = this._builderFactory.getCoreFactory().locate( "empty" );
		Assert.equals( 0, empty.length, "" );

		var fruits : Array<MockFruitVO> = this._builderFactory.getCoreFactory().locate( "fruits" );
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
		this.build( XmlReader.readXmlFile( "context/hashmapFilledWithReferences.xml" ) );

		var fruits : HashMap<Dynamic, MockFruitVO> = this._builderFactory.getCoreFactory().locate( "fruits" );
		Assert.isNotNull( fruits, "" );

		var stubKey : Point = this._builderFactory.getCoreFactory().locate( "stubKey" );
		Assert.isNotNull( stubKey, "" );

		var orange 	: MockFruitVO = fruits.get( '0' );
		var apple 	: MockFruitVO = fruits.get( 1 );
		var banana 	: MockFruitVO = fruits.get( stubKey );

		Assert.equals( "orange", orange.toString(), "" );
		Assert.equals( "apple", apple.toString(), "" );
		Assert.equals( "banana", banana.toString(), "" );
	}
	
	@Test( "test building two modules listening each other" )
	public function testBuildingTwoModulesListeningEachOther() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/twoModulesListeningEachOther.xml" ) );

		var chat : MockChatModule = this._builderFactory.getCoreFactory().locate( "chat" );
		Assert.isNotNull( chat, "" );
		Assert.isNull( chat.translatedMessage, "" );

		var translation : MockTranslationModule = this._builderFactory.getCoreFactory().locate( "translation" );
		Assert.isNotNull( translation, "" );

		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "Hello", chat.translatedMessage, "" );
	}
	
	@Test( "test building two modules listening each other with adapter" )
	public function testBuildingTwoModulesListeningEachOtherWithAdapter() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/twoModulesListeningEachOtherWithAdapter.xml" ) );

		var chat : MockChatModule = this._builderFactory.getCoreFactory().locate( "chat" );
		Assert.isNotNull( chat, "" );
		Assert.isNull( chat.translatedMessage, "" );

		var translation : MockTranslationModule = this._builderFactory.getCoreFactory().locate( "translation" );
		Assert.isNotNull( translation, "" );

		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "Hello", chat.translatedMessage, "" );
		Assert.isInstanceOf( chat.date, Date, "" );
	}
	
	@Test( "test building two modules listening each other with adapter and injection" )
	public function testBuildingTwoModulesListeningEachOtherWithAdapterAndInjection() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/twoModulesListeningEachOtherWithAdapterAndInjection.xml" ) );

		var chat : MockChatModule = this._builderFactory.getCoreFactory().locate( "chat" );
		Assert.isNotNull( chat, "" );

		var receiver : MockReceiverModule = this._builderFactory.getCoreFactory().locate( "receiver" );
		Assert.isNotNull( receiver, "" );

		var parser : MockMessageParserModule = this._builderFactory.getCoreFactory().locate( "parser" );
		Assert.isNotNull( parser, "" );

		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "BONJOUR", receiver.message, "" );
	}
	
	@Test( "test domain dispatch after module initialisation" )
	public function testDomainDispatchAfterModuleInitialisation() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/domainDispatchAfterModuleInitialisation.xml" ) );

		var sender : MockSenderModule = this._builderFactory.getCoreFactory().locate( "sender" );
		Assert.isNotNull( sender, "" );

		var receiver : MockReceiverModule = this._builderFactory.getCoreFactory().locate( "receiver" );
		Assert.isNotNull( receiver, "" );

		Assert.equals( "hello receiver", receiver.message, "" );
	}
	
	@Ignore( "test building different applicationContext" )
	public function testBuildingDifferentApplicationContext() : Void
	{
		var parentSource : String = '
		<root name="applicationContextParent">

			<bean id="rect0" type="hex.ioc.parser.xml.mock.MockRectangle">
				<argument type="Int" value="10"/>
				<argument type="Int" value="20"/>
				<argument type="Int" value="30"/>
				<argument ref="applicationContextChild.applicationContextSubChild.rect0.height"/>
			</bean>

		</root>';

		var childSource : String = '
		<root name="applicationContextChild" parent="applicationContextParent">

			<bean id="rect0" type="hex.ioc.parser.xml.mock.MockRectangle">
				<argument type="Int" value="40"/>
				<argument type="Int" value="50"/>
				<argument type="Int" value="60"/>
				<argument type="Int" value="70"/>
			</bean>

		</root>';

		var subChildSource : String = '
		<root name="applicationContextSubChild" parent="applicationContextChild">

			<bean id="rect0" type="hex.ioc.parser.xml.mock.MockRectangle">
				<argument type="Int" value="80"/>
				<argument type="Int" value="90"/>
				<argument type="Int" value="100"/>
				<argument type="Int" value="110"/>
			</bean>

		</root>';

		var applicationContextParent : AbstractApplicationContext	= this._applicationAssembler.getApplicationContext( "applicationContextParent" );
		var applicationContextChild 	= this._applicationAssembler.getApplicationContext( "applicationContextChild" );
		var applicationContextSubChild 	= this._applicationAssembler.getApplicationContext( "applicationContextSubChild" );

		applicationContextParent.addChild( applicationContextChild );
		applicationContextChild.addChild( applicationContextSubChild );

		this._build( Xml.parse( subChildSource ), applicationContextSubChild );
		this._build( Xml.parse( childSource ), applicationContextChild );
		this._build( Xml.parse( parentSource ), applicationContextParent );

		var builderFactory : IContextFactory;

		builderFactory = this._applicationAssembler.getContextFactory( applicationContextParent );
		var parentRectangle  : MockRectangle = builderFactory.getCoreFactory().locate( "rect0" );
		Assert.isInstanceOf( parentRectangle, MockRectangle, "" );
		Assert.equals( 10, parentRectangle.x, "" );
		Assert.equals( 20, parentRectangle.y, "" );
		Assert.equals( 30, parentRectangle.width, "" );
		Assert.equals( 110, parentRectangle.height, "" );

		builderFactory = this._applicationAssembler.getContextFactory( applicationContextChild );
		var childRectangle : MockRectangle = builderFactory.getCoreFactory().locate( "rect0" );
		Assert.isInstanceOf( childRectangle, MockRectangle, "" );
		Assert.equals( 40, childRectangle.x, "" );
		Assert.equals( 50, childRectangle.y, "" );
		Assert.equals( 60, childRectangle.width, "" );
		Assert.equals( 70, childRectangle.height, "" );

		builderFactory = this._applicationAssembler.getContextFactory( applicationContextSubChild );
		var subChildRectangle : MockRectangle = builderFactory.getCoreFactory().locate( "rect0" );
		Assert.isInstanceOf( subChildRectangle, MockRectangle, "" );
		Assert.equals( 80, subChildRectangle.x, "" );
		Assert.equals( 90, subChildRectangle.y, "" );
		Assert.equals( 100, subChildRectangle.width, "" );
		Assert.equals( 110, subChildRectangle.height, "" );

		Assert.equals( applicationContextChild, applicationContextParent.applicationContextChild, "" );
		Assert.equals( childRectangle, applicationContextParent.applicationContextChild.rect0, "" );
		Assert.equals( subChildRectangle, applicationContextParent.applicationContextChild.applicationContextSubChild.rect0, "" );
	}
	
	@Test( "test target sub property" )
	public function testTargetSubProperty() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/targetSubProperty.xml" ) );

		var mockObject : MockObjectWithRegtangleProperty = this._builderFactory.getCoreFactory().locate( "mockObject" );
		Assert.isInstanceOf( mockObject, MockObjectWithRegtangleProperty, "" );
		Assert.equals( 1.5, mockObject.rectangle.x, "" );
	}
	
	@Test( "test building class reference" )
	public function testBuildingClassReference() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/classReference.xml" ) );

		var rectangleClass : Class<MockRectangle> = this._builderFactory.getCoreFactory().locate( "RectangleClass" );
		Assert.isInstanceOf( rectangleClass, Class, "" );
		Assert.isInstanceOf( Type.createInstance( rectangleClass, [] ), MockRectangle, "" );

		var classContainer = this._builderFactory.getCoreFactory().locate( "classContainer" );

		var anotherRectangleClass : Class<MockRectangle> = classContainer.AnotherRectangleClass;
		Assert.isInstanceOf( anotherRectangleClass, Class, "" );
		Assert.isInstanceOf( Type.createInstance( anotherRectangleClass, [] ), MockRectangle, "" );

		Assert.equals( rectangleClass, anotherRectangleClass, "" );

		var anotherRectangleClassRef : Class<MockRectangle> = this._builderFactory.getCoreFactory().locate( "classContainer.AnotherRectangleClass" );
		Assert.isInstanceOf( anotherRectangleClassRef, Class, "" );
		Assert.equals( anotherRectangleClass, anotherRectangleClassRef, "" );
	}
	
	@Test( "test building mapping configuration" )
	public function testBuildingMappingConfiguration() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/mappingConfiguration.xml" ) );

		var config : MappingConfiguration = this._builderFactory.getCoreFactory().locate( "config" );
		Assert.isInstanceOf( config, MappingConfiguration, "" );

		var injector = new Injector();
		config.configure( injector, new Dispatcher(), null );

		Assert.isInstanceOf( injector.getInstance( IMockAmazonService ), MockAmazonService, "" );
		Assert.isInstanceOf( injector.getInstance( IMockFacebookService ), MockFacebookService, "" );
		Assert.equals( this._builderFactory.getCoreFactory().locate( "facebookService" ), injector.getInstance( IMockFacebookService ), "" );
	}
	
	@Test( "test building mapping configuration with map names" )
	public function testBuildingMappingConfigurationWithMapNames() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/mappingConfigurationWithMapNames.xml" ) );

		var config : MappingConfiguration = this._builderFactory.getCoreFactory().locate( "config" );
		Assert.isInstanceOf( config, MappingConfiguration, "" );

		var injector = new Injector();
		config.configure( injector, new Dispatcher(), null );

		Assert.isInstanceOf( injector.getInstance( IMockAmazonService, "amazon0" ),  MockAmazonService, "" );
		Assert.isInstanceOf( injector.getInstance( IMockAmazonService, "amazon1" ), AnotherMockAmazonService, "" );
	}
	
	@Test( "test building mapping configuration with singleton" )
	public function testBuildingMappingConfigurationWithSingleton() : Void
	{
		this.build( XmlReader.readXmlFile( "context/mappingConfigurationWithSingleton.xml" ) );

		var config = this._builderFactory.getCoreFactory().locate( "config" );
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
		this.build(  XmlReader.readXmlFile( "context/serviceLocator.xml" ) );

		var serviceLocator : ServiceLocator = this._builderFactory.getCoreFactory().locate( "serviceLocator" );
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
		this.build(  XmlReader.readXmlFile( "context/serviceLocatorWithMapNames.xml" ) );

		var serviceLocator : ServiceLocator = this._builderFactory.getCoreFactory().locate( "serviceLocator" );
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
	
	@Test( "test parsing twice" )
	public function testParsingTwice() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/mockRectangle.xml" ) );
		this.build(  XmlReader.readXmlFile( "context/mockRectangleCopy.xml" ) );

		var rect0 : MockRectangle = this._builderFactory.getCoreFactory().locate( "rect0" );
		Assert.isInstanceOf( rect0, MockRectangle, "" );
		Assert.equals( 10, rect0.x, "" );
		Assert.equals( 20, rect0.y, "" );
		Assert.equals( 30, rect0.width, "" );
		Assert.equals( 40, rect0.height, "" );

		var rect1 : MockRectangle = this._builderFactory.getCoreFactory().locate( "rect1" );
		Assert.isInstanceOf( rect1, MockRectangle, "" );
		Assert.equals( 50, rect1.x, "" );
		Assert.equals( 60, rect1.y, "" );
		Assert.equals( 70, rect1.width, "" );
		Assert.equals( 40, rect1.height, "" );
	}
	
	@Test( "test module listening service" )
	public function testModuleListeningService() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/moduleListeningService.xml" ) );

		var myService : IMockStubStatefulService = this._builderFactory.getCoreFactory().locate( "myService" );
		Assert.isNotNull( myService, "" );

		var myModule : MockModuleWithServiceCallback = this._builderFactory.getCoreFactory().locate( "myModule" );
		Assert.isNotNull( myModule, "" );

		var booleanVO = new MockBooleanVO( true );
		myService.setBooleanVO( booleanVO );
		Assert.isTrue( myModule.getBooleanValue(), "" );
	}
	
	@Test( "test module listening service with strategy and module injection" )
	public function testModuleListeningServiceWithStrategyAndModuleInjection() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/moduleListeningServiceWithStrategyAndModuleInjection.xml" ) );

		var myService : IMockStubStatefulService = this._builderFactory.getCoreFactory().locate( "myService" );
		Assert.isNotNull( myService, "" );

		var myModule : MockModuleWithServiceCallback = this._builderFactory.getCoreFactory().locate( "myModule" );
		Assert.isNotNull( myModule, "" );

		var intVO = new MockIntVO( 7 );
		myService.setIntVO( intVO );
		Assert.equals( 3.5, ( myModule.getFloatValue() ), "" );
	}
	
	@Test( "test module listening service with strategy and context injection" )
	public function testModuleListeningServiceWithStrategyAndContextInjection() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/moduleListeningServiceWithStrategyAndContextInjection.xml" ) );

		var mockDividerHelper : IMockDividerHelper = this._builderFactory.getCoreFactory().locate( "mockDividerHelper" );
		Assert.isNotNull( mockDividerHelper, "" );

		var myService : IMockStubStatefulService = this._builderFactory.getCoreFactory().locate( "myService" );
		Assert.isNotNull( myService, "" );

		var myModuleA : MockModuleWithServiceCallback = this._builderFactory.getCoreFactory().locate( "myModuleA" );
		Assert.isNotNull( myModuleA, "" );

		var myModuleB : AnotherMockModuleWithServiceCallback = this._builderFactory.getCoreFactory().locate( "myModuleB" );
		Assert.isNotNull( myModuleB, "" );

		myService.setIntVO( new MockIntVO( 7 ) );
		Assert.equals( 3.5, ( myModuleA.getFloatValue() ), "" );

		myService.setIntVO( new MockIntVO( 9 ) );
		Assert.equals( 4.5, ( myModuleB.getFloatValue() ), "" );
	}
	
	@Test( "test static-ref" )
	public function testStaticRef() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/staticRef.xml" ) );

		var note : String = this._builderFactory.getCoreFactory().locate( "constant" );
		Assert.isNotNull( note, "" );
		Assert.equals( note, MockStubStatefulService.INT_VO_UPDATE, "" );
	}
	
	@Test( "test static-ref property" )
	public function testStaticRefProperty() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/staticRefProperty.xml" ) );

		var object : Dynamic = this._builderFactory.getCoreFactory().locate( "object" );
		Assert.isNotNull( object, "" );
		Assert.equals( object.property, MockStubStatefulService.INT_VO_UPDATE, "" );
	}
	
	@Test( "test static-ref argument" )
	public function testStaticRefArgument() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/staticRefArgument.xml" ) );

		var instance : ClassWithConstantConstantArgument = this._builderFactory.getCoreFactory().locate( "instance" );
		Assert.isNotNull( instance, "" );
		Assert.equals( instance.constant, MockStubStatefulService.INT_VO_UPDATE, "" );
	}
	
	@Async( "test EventProxy" )
	public function testEventProxy() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/eventProxy.xml" ) );

		var eventProxy : EventProxy = this._builderFactory.getCoreFactory().locate( "eventProxy" );
		Assert.isNotNull( eventProxy, "" );

		var chat : MockChatModule = this._builderFactory.getCoreFactory().locate( "chat" );
		Assert.isNotNull( chat, "" );

		var receiver : MockReceiverModule = this._builderFactory.getCoreFactory().locate( "receiver" );
		Assert.isNotNull( receiver, "" );

		var eventProxy : EventProxy = this._builderFactory.getCoreFactory().locate( "eventProxy" );
		Assert.isNotNull( eventProxy, "" );

		var parser : MockMessageParserModule = this._builderFactory.getCoreFactory().locate( "parser" );
		Assert.isNotNull( parser, "" );

		Timer.delay( MethodRunner.asyncHandler( this._onCompleteHandler ), 500 );
		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "bonjour" ] );
	}
	
	function _onCompleteHandler() : Void
	{
		var receiver : MockReceiverModule = this._builderFactory.getCoreFactory().locate( "receiver" );
		Assert.equals( "BONJOUR:HTTP://GOOGLE.COM", receiver.message, "" );
	}
	
	@Async( "test EventTrigger" )
	public function testEventTrigger() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/eventTrigger.xml" ) );

		var eventTrigger : Dynamic = this._builderFactory.getCoreFactory().locate( "eventTrigger" );
		Assert.isNotNull( eventTrigger, "" );
		
		var chat : MockChatModule = this._builderFactory.getCoreFactory().locate( "chat" );
		Assert.isNotNull( chat, "" );

		var receiver : MockReceiverModule = this._builderFactory.getCoreFactory().locate( "receiver" );
		Assert.isNotNull( receiver, "" );

		var parser : MockMessageParserModule = this._builderFactory.getCoreFactory().locate( "parser" );
		Assert.isNotNull( parser, "" );

		Timer.delay( MethodRunner.asyncHandler( this._onCompleteHandler ), 500 );
		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "bonjour" ] );
	}
	
	@Test( "test map-type attribute" )
	public function testMapTypeAttribute() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/mapTypeAttribute.xml" ) );

		var myModule : MockMappedModule = this._builderFactory.getCoreFactory().locate( "myModule" );
		Assert.isNotNull( myModule, "" );
		Assert.isInstanceOf( myModule, MockMappedModule, "" );
		
		Assert.equals( myModule, this._applicationContext.getInjector().getInstance( IMockMappedModule, "myModule" ), "" );
	}
	
	@Test( "test if attribute" )
	public function testIfAttribute() : Void
	{
		this._applicationAssembler.addConditionalProperty ( ["production" => true, "debug" => false, "release" => false] );
		this.build(  XmlReader.readXmlFile( "context/ifAttribute.xml" ) );
		
		Assert.equals( "hello production", this._builderFactory.getCoreFactory().locate( "message" ), "message value should equal 'hello production'" );
	}
	
	@Test( "test file preprocessor" )
	public function testFilePreprocessor() : Void
	{
		//$$ is used to escape haxe String interpolation.
		var source : String = '
		<root $${context}>

			$${node}

		</root>';

		var preprocessor = new Preprocessor();
		preprocessor.addProperty( "hello", "bonjour" );
		preprocessor.addProperty( "contextName", 'applicationContext' );
		preprocessor.addProperty( "context", 'name="$${contextName}"' );
		preprocessor.addProperty( "node", '<msg id="message" value="$${hello}"/>' );

		var xml : Xml = Xml.parse( preprocessor.parse( source ) );
		this._build( xml );

		Assert.equals( "bonjour", this._builderFactory.getCoreFactory().locate( "message" ), "message value should equal 'bonjour'" );
	}

	@Test( "test file preprocessor" )
	public function testAnotherFilePreprocessor() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/preprocessor.xml", [	"hello" 		=> "bonjour",
																					"contextName" 	=> 'applicationContext',
																					"context" 		=> 'name="${contextName}"',
																					"node" 			=> '<msg id="message" value="${hello}"/>' ] ) );

		Assert.equals( "bonjour", this._builderFactory.getCoreFactory().locate( "message" ), "message value should equal 'bonjour'" );
	}

	@Test( "test file preprocessor with include" )
	public function testFilePreprocessorWithInclude() : Void
	{
		this.build(  XmlReader.readXmlFile( "context/preprocessorWithInclude.xml", [	"hello" 		=> "bonjour",
																					"contextName" 	=> 'applicationContext',
																					"context" 		=> 'name="${contextName}"',
																					"node" 			=> '<msg id="message" value="${hello}"/>' ] ) );

		Assert.equals( "bonjour", this._builderFactory.getCoreFactory().locate( "message" ), "message value should equal 'bonjour'" );
	}
}