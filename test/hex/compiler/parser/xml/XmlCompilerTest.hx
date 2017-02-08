package hex.compiler.parser.xml;

import haxe.Timer;
import hex.collection.HashMap;
import hex.control.command.BasicCommand;
import hex.core.IApplicationAssembler;
import hex.core.ICoreFactory;
import hex.di.Injector;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.domain.DomainUtil;
import hex.error.Exception;
import hex.error.NoSuchElementException;
import hex.event.Dispatcher;
import hex.event.EventProxy;
import hex.ioc.assembler.ApplicationContext;
import hex.di.mapping.MappingConfiguration;
import hex.ioc.parser.xml.ApplicationXMLParser;
import hex.ioc.parser.xml.mock.AnotherMockAmazonService;
import hex.ioc.parser.xml.mock.AnotherMockModuleWithServiceCallback;
import hex.ioc.parser.xml.mock.ClassWithConstantConstantArgument;
import hex.ioc.parser.xml.mock.IAnotherMockMappedModule;
import hex.ioc.parser.xml.mock.IMockAmazonService;
import hex.ioc.parser.xml.mock.IMockDividerHelper;
import hex.ioc.parser.xml.mock.IMockFacebookService;
import hex.ioc.parser.xml.mock.IMockInjectee;
import hex.ioc.parser.xml.mock.IMockMappedModule;
import hex.ioc.parser.xml.mock.IMockStubStatefulService;
import hex.ioc.parser.xml.mock.MockAmazonService;
import hex.ioc.parser.xml.mock.MockAsyncCommandWithAnnotation;
import hex.ioc.parser.xml.mock.MockBooleanVO;
import hex.ioc.parser.xml.mock.MockCaller;
import hex.ioc.parser.xml.mock.MockChatModule;
import hex.ioc.parser.xml.mock.MockClassWithGeneric;
import hex.ioc.parser.xml.mock.MockClassWithInjectedProperty;
import hex.ioc.parser.xml.mock.MockCommandWithAnnotation;
import hex.ioc.parser.xml.mock.MockDocument;
import hex.ioc.parser.xml.mock.MockFacebookService;
import hex.ioc.parser.xml.mock.MockFruitVO;
import hex.ioc.parser.xml.mock.MockInjectee;
import hex.ioc.parser.xml.mock.MockIntVO;
import hex.ioc.parser.xml.mock.MockMacroWithAnnotation;
import hex.ioc.parser.xml.mock.MockMappedModule;
import hex.ioc.parser.xml.mock.MockMessageParserModule;
import hex.ioc.parser.xml.mock.MockMethodCaller;
import hex.ioc.parser.xml.mock.MockModuleWithAnnotationProviding;
import hex.ioc.parser.xml.mock.MockModuleWithServiceCallback;
import hex.ioc.parser.xml.mock.MockObjectWithRegtangleProperty;
import hex.ioc.parser.xml.mock.MockReceiverModule;
import hex.ioc.parser.xml.mock.MockRectangle;
import hex.ioc.parser.xml.mock.MockSenderModule;
import hex.ioc.parser.xml.mock.MockServiceProvider;
import hex.ioc.parser.xml.mock.MockStubStatefulService;
import hex.ioc.parser.xml.mock.MockTranslationModule;
import hex.metadata.AnnotationProvider;
import hex.metadata.IAnnotationProvider;
import hex.runtime.ApplicationAssembler;
import hex.structures.Point;
import hex.structures.Size;
import hex.unittest.assertion.Assert;
import hex.unittest.runner.MethodRunner;

/**
 * ...
 * @author Francis Bourre
 */
class XmlCompilerTest
{
	var _applicationAssembler 		: IApplicationAssembler;
	
	static var applicationAssembler : IApplicationAssembler;

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
		return this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory().locate( key );
	}
	
	@Test( "test building String with assembler" )
	public function testBuildingStringWithAssembler() : Void
	{
		var assembler = new ApplicationAssembler();
		assembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory().register( "s2", "bonjour" );
		
		this._applicationAssembler = XmlCompiler.readXmlFileWithAssembler( assembler, "context/testBuildingString.xml" );

		Assert.equals( "hello", this._locate( "s" ), "" );
		Assert.equals( "bonjour", this._locate( "s2" ), "" );
		Assert.equals( assembler, this._applicationAssembler, "" );
	}
	
	@Test( "test building String instances with the same assembler at compile time and runtime" )
	public function testBuildingStringsMixingCompileTimeAndRuntime() : Void
	{
		var assembler = new ApplicationAssembler();
		ApplicationXMLParser.parseString( assembler, '<root name="applicationContext"><test id="s2" value="hola"/></root>' );
		this._applicationAssembler = XmlCompiler.readXmlFileWithAssembler( assembler, "context/testBuildingString.xml" );

		Assert.equals( "hello", this._locate( "s" ), "" );
		Assert.equals( "hola", this._locate( "s2" ), "" );
		Assert.equals( assembler, this._applicationAssembler, "" );
	}
	
	@Test( "test building String" )
	public function testBuildingString() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/testBuildingString.xml" );
		var s : String = this._locate( "s" );
		Assert.equals( "hello", s, "" );
	}
	
	@Test( "test building String with assembler property" )
	public function testBuildingStringWithAssemblerProperty() : Void
	{
		this._applicationAssembler = new ApplicationAssembler();
		XmlCompiler.readXmlFileWithAssembler( this._applicationAssembler, "context/testBuildingString.xml" );
		var s : String = this._locate( "s" );
		Assert.equals( "hello", s, "" );
	}
	
	@Ignore( "test building String with assembler static property" )
	public function testBuildingStringWithAssemblerStaticProperty() : Void
	{
		XmlCompilerTest.applicationAssembler = new ApplicationAssembler();
		XmlCompiler.readXmlFileWithAssembler( XmlCompilerTest.applicationAssembler, "context/testBuildingString.xml" );
		var s : String = this._locate( "s" );
		Assert.equals( "hello", s, "" );
	}
	
	@Test( "test read twice the same context" )
	public function testReadTwiceTheSameContext() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		this._applicationAssembler = new ApplicationAssembler();
		
		XmlCompiler.readXmlFileWithAssembler( applicationAssembler, "context/simpleInstanceWithoutArguments.xml" );
		XmlCompiler.readXmlFileWithAssembler( this._applicationAssembler, "context/simpleInstanceWithoutArguments.xml" );
		
		var coreFactory = applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory();

		var command1 = coreFactory.locate( "command" );
		Assert.isInstanceOf( command1, BasicCommand );
		
		var command2 = this._locate( "command" );
		Assert.isInstanceOf( command2, BasicCommand );
		
		Assert.notEquals( command1, command2 );
	}
	
	@Test( "test building Int" )
	public function testBuildingInt() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/testBuildingInt.xml" );
		var i : Int = this._locate( "i" );
		Assert.equals( -3, i, "" );
	}
	
	@Test( "test building Hex" )
	public function testBuildingHex() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/testBuildingHex.xml" );
		Assert.equals( 0xFFFFFF, this._locate( "i" ) );
	}
	
	@Test( "test building Bool" )
	public function testBuildingBool() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/testBuildingBool.xml" );
		var b : Bool = this._locate( "b" );
		Assert.isTrue( b, "" );
	}
	
	@Test( "test building UInt" )
	public function testBuildingUInt() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/testBuildingUInt.xml" );
		var i : UInt = this._locate( "i" );
		Assert.equals( 3, i, "" );
	}
	
	@Test( "test building null" )
	public function testBuildingNull() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/testBuildingNull.xml" );
		var result : Dynamic = this._locate( "value" );
		Assert.isNull( result, "" );
	}
	
	@Test( "test building anonymous object" )
	public function testBuildingAnonymousObject() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/anonymousObject.xml" );
		var obj : Dynamic = this._locate( "obj" );

		Assert.equals( "Francis", obj.name, "" );
		Assert.equals( 44, obj.age, "" );
		Assert.equals( 1.75, obj.height, "" );
		Assert.isTrue( obj.isWorking, "" );
		Assert.isFalse( obj.isSleeping, "" );
		Assert.equals( 1.75, this._locate( "obj.height" ), "" );
	}
	
	@Test( "test building simple instance without arguments" )
	public function testBuildingSimpleInstanceWithoutArguments() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/simpleInstanceWithoutArguments.xml" );

		var command : BasicCommand = this._locate( "command" );
		Assert.isInstanceOf( command, BasicCommand, "" );
	}
	
	@Test( "test building simple instance with arguments" )
	public function testBuildingSimpleInstanceWithArguments() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/simpleInstanceWithArguments.xml" );

		var size : Size = this._locate( "size" );
		Assert.isInstanceOf( size, Size, "" );
		Assert.equals( 10, size.width, "" );
		Assert.equals( 20, size.height, "" );
	}
	
	@Test( "test building multiple instances with arguments" )
	public function testBuildingMultipleInstancesWithArguments() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/multipleInstancesWithArguments.xml" );

		var size : Size = this._locate( "size" );
		Assert.isInstanceOf( size, Size, "" );
		Assert.equals( 15, size.width, "" );
		Assert.equals( 25, size.height, "" );

		var position : Point = this._locate( "position" );
		//Assert.isInstanceOf( position, Point, "" );
		Assert.equals( 35, position.x, "" );
		Assert.equals( 45, position.y, "" );
	}
	
	@Test( "test building single instance with primitives references" )
	public function testBuildingSingleInstanceWithPrimitivesReferences() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/singleInstanceWithPrimReferences.xml" );
		
		var x : Int = this._locate( "x" );
		Assert.equals( 1, x, "" );
		
		var y : Int = this._locate( "y" );
		Assert.equals( 2, y, "" );

		var position : Point = this._locate( "position" );
		//Assert.isInstanceOf( position, Point, "" );
		Assert.equals( 1, position.x, "" );
		Assert.equals( 2, position.y, "" );
	}
	
	@Test( "test building single instance with object references" )
	public function testBuildingSingleInstanceWithObjectReferences() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/singleInstanceWithObjectReferences.xml" );
		
		var chat : MockChatModule = this._locate( "chat" );
		Assert.isInstanceOf( chat, MockChatModule, "" );
		
		var receiver : MockReceiverModule = this._locate( "receiver" );
		Assert.isInstanceOf( receiver, MockReceiverModule, "" );
		
		var proxyChat : EventProxy = this._locate( "proxyChat" );
		Assert.isInstanceOf( proxyChat, EventProxy, "" );
		
		var proxyReceiver : EventProxy = this._locate( "proxyReceiver" );
		Assert.isInstanceOf( proxyReceiver, EventProxy, "" );

		Assert.equals( chat, proxyChat.scope, "" );
		Assert.equals( chat.onTranslation, proxyChat.callback, "" );
		
		Assert.equals( receiver, proxyReceiver.scope, "" );
		Assert.equals( receiver.onMessage, proxyReceiver.callback, "" );
	}
	
	@Test( "test building multiple instances with references" )
	public function testAssignInstancePropertyWithReference() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/instancePropertyWithReference.xml" );
		
		var width : Int = this._locate( "width" );
		Assert.equals( 10, width, "" );
		
		var height : Int = this._locate( "height" );
		Assert.equals( 20, height, "" );
		
		var size : Point = this._locate( "size" );
		//Assert.isInstanceOf( size, Point, "" );
		Assert.equals( width, size.x, "" );
		Assert.equals( height, size.y, "" );
		
		var rect : MockRectangle = this._locate( "rect" );
		Assert.equals( width, rect.size.x, "" );
		Assert.equals( height, rect.size.y, "" );
	}
	
	@Test( "test building multiple instances with references" )
	public function testBuildingMultipleInstancesWithReferences() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/multipleInstancesWithReferences.xml" );

		var rectSize : Point = this._locate( "rectSize" );
		//Assert.isInstanceOf( rectSize, Point, "" );
		Assert.equals( 30, rectSize.x, "" );
		Assert.equals( 40, rectSize.y, "" );

		var rectPosition : Point = this._locate( "rectPosition" );
		//Assert.isInstanceOf( rectPosition, Point, "" );
		Assert.equals( 10, rectPosition.x, "" );
		Assert.equals( 20, rectPosition.y, "" );

		var rect : MockRectangle = this._locate( "rect" );
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

		var caller : MockCaller = this._locate( "caller" );
		Assert.isInstanceOf( caller, MockCaller, "" );
		Assert.deepEquals( [ "hello", "world" ], MockCaller.passedArguments, "" );
	}
	
	@Test( "test simple method call from another node" )
	public function testSimpleMethodCallFromAnotherNode() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/simpleMethodCallFromAnotherNode.xml" );

		var caller : MockCaller = this._locate( "caller" );
		Assert.isInstanceOf( caller, MockCaller, "" );
		Assert.deepEquals( [ "hello", "world" ], MockCaller.passedArguments, "" );
	}
	
	@Test( "test method call with type params" )
	public function testCallWithTypeParams() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/methodCallWithTypeParams.xml" );

		var caller : MockCaller = this._locate( "caller" );
		Assert.isInstanceOf( caller, MockCaller, "" );
		Assert.equals( 3, MockCaller.passedArray.length, "" );
	}
	
	@Test( "test building multiple instances with method calls" )
	public function testBuildingMultipleInstancesWithMethodCall() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/multipleInstancesWithMethodCall.xml" );

		var rectSize : Point = this._locate( "rectSize" );
		//Assert.isInstanceOf( rectSize, Point, "" );
		Assert.equals( 30, rectSize.x, "" );
		Assert.equals( 40, rectSize.y, "" );

		var rectPosition : Point = this._locate( "rectPosition" );
		//Assert.isInstanceOf( rectPosition, Point, "" );
		Assert.equals( 10, rectPosition.x, "" );
		Assert.equals( 20, rectPosition.y, "" );


		var rect : MockRectangle = this._locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle, "" );
		Assert.equals( 10, rect.x, "" );
		Assert.equals( 20, rect.y, "" );
		Assert.equals( 30, rect.width, "" );
		Assert.equals( 40, rect.height, "" );

		var anotherRect : MockRectangle = this._locate( "anotherRect" );
		Assert.isInstanceOf( anotherRect, MockRectangle, "" );
		Assert.equals( 0, anotherRect.x, "" );
		Assert.equals( 0, anotherRect.y, "" );
		Assert.equals( 0, anotherRect.width, "" );
		Assert.equals( 0, anotherRect.height, "" );
	}
	
	@Test( "test building instance with static method" )
	public function testBuildingInstanceWithStaticMethod() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/instanceWithStaticMethod.xml" );

		var service : MockServiceProvider = this._locate( "service" );
		Assert.isInstanceOf( service, MockServiceProvider, "" );
		Assert.equals( "http://localhost/amfphp/gateway.php", MockServiceProvider.getInstance().getGateway(), "" );
	}
	
	@Test( "test building instance with static method and arguments" )
	public function testBuildingInstanceWithStaticMethodAndArguments() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/instanceWithStaticMethodAndArguments.xml" );

		var rect : MockRectangle = this._locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle, "" );
		Assert.equals( 10, rect.x, "" );
		Assert.equals( 20, rect.y, "" );
		Assert.equals( 30, rect.width, "" );
		Assert.equals( 40, rect.height, "" );
	}
	
	@Test( "test building instance with static method and factory method" )
	public function testBuildingInstanceWithStaticMethodAndFactoryMethod() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/instanceWithStaticMethodAndFactoryMethod.xml" );

		var point : Point = this._locate( "point" );
		//Assert.isInstanceOf( point, Point, "" );
		Assert.equals( 10, point.x, "" );
		Assert.equals( 20, point.y, "" );
	}
	
	@Test( "test 'injector-creation' attribute" )
	public function testInjectorCreationAttribute() : Void
	{
		var assembler = new ApplicationAssembler();
		var injector = assembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory().getInjector();
		injector.mapToValue( String, 'hola mundo' );
		
		this._applicationAssembler = XmlCompiler.readXmlFileWithAssembler( assembler, "context/injectorCreationAttribute.xml" );

		var instance : MockClassWithInjectedProperty = this._locate( "instance" );
		Assert.isInstanceOf( instance, MockClassWithInjectedProperty, "" );
		Assert.equals( "hola mundo", instance.property, "" );
		Assert.isTrue( instance.postConstructWasCalled, "" );
	}
	
	@Test( "test 'inject-into' attribute" )
	public function testInjectIntoAttribute() : Void
	{
		var assembler = new ApplicationAssembler();
		var injector = assembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory().getInjector();
		injector.mapToValue( String, 'hola mundo' );

		this._applicationAssembler = XmlCompiler.readXmlFileWithAssembler( assembler, "context/injectIntoAttribute.xml" );

		var instance : MockClassWithInjectedProperty = this._locate( "instance" );
		Assert.isInstanceOf( instance, MockClassWithInjectedProperty, "" );
		Assert.equals( "hola mundo", instance.property, "" );
		Assert.isTrue( instance.postConstructWasCalled, "" );
	}
	
	@Test( "test building XML without parser class" )
	public function testBuildingXMLWithoutParserClass() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/xmlWithoutParserClass.xml" );

		var fruits : Xml = this._locate( "fruits" );
		Assert.isNotNull( fruits );
		Assert.isInstanceOf( fruits, Xml );
	}
	
	@Test( "test building XML with parser class" )
	public function testBuildingXMLWithParserClass() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/xmlWithParserClass.xml" );

		var fruits : Array<MockFruitVO> = this._locate( "fruits" );
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
		
		var text : Array<String> = this._locate( "text" );
		Assert.equals( 2, text.length, "" );
		Assert.equals( "hello", text[ 0 ], "" );
		Assert.equals( "world", text[ 1 ], "" );
		
		var empty : Array<String> = this._locate( "empty" );
		Assert.equals( 0, empty.length, "" );

		var fruits : Array<MockFruitVO> = this._locate( "fruits" );
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

		var fruits : HashMap<Dynamic, MockFruitVO> = this._locate( "fruits" );
		Assert.isNotNull( fruits, "" );

		var stubKey : Point = this._locate( "stubKey" );
		Assert.isNotNull( stubKey, "" );

		var orange 	: MockFruitVO = fruits.get( '0' );
		var apple 	: MockFruitVO = fruits.get( 1 );
		var banana 	: MockFruitVO = fruits.get( stubKey );

		Assert.equals( "orange", orange.toString(), "" );
		Assert.equals( "apple", apple.toString(), "" );
		Assert.equals( "banana", banana.toString(), "" );
	}
	
	@Test( "test building HashMap with map-type" )
	public function testBuildingHashMapWithMapType() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/hashmapWithMapType.xml" );

		var fruits : HashMap<Dynamic, MockFruitVO> = this._locate( "fruits" );
		Assert.isNotNull( fruits, "" );

		var orange 	: MockFruitVO = fruits.get( '0' );
		var apple 	: MockFruitVO = fruits.get( '1' );

		Assert.equals( "orange", orange.toString(), "" );
		Assert.equals( "apple", apple.toString(), "" );
		
		var map = this._getCoreFactory().getInjector().getInstanceWithClassName( "hex.collection.HashMap<String,hex.ioc.parser.xml.mock.MockFruitVO>", "fruits" );
		Assert.equals( fruits, map );
	}
	
	@Test( "test map-type attribute with Array" )
	public function testMapTypeWithArray() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/testMapTypeWithArray.xml" );
		
		var intCollection = this._getCoreFactory().getInjector().getInstanceWithClassName( "Array<Int>", "intCollection" );
		var uintCollection = this._getCoreFactory().getInjector().getInstanceWithClassName( "Array<UInt>", "intCollection" );
		var stringCollection = this._getCoreFactory().getInjector().getInstanceWithClassName( "Array<String>", "stringCollection" );
		
		Assert.isInstanceOf( intCollection, Array );
		Assert.isInstanceOf( uintCollection, Array );
		Assert.isInstanceOf( stringCollection, Array );
		
		Assert.equals( intCollection, uintCollection );
		Assert.notEquals( intCollection, stringCollection );
	}
	
	@Test( "test map-type attribute with instance" )
	public function testMapTypeWithInstance() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/testMapTypeWithInstance.xml" );
		
		var intInstance = this._getCoreFactory().getInjector().getInstanceWithClassName( "hex.ioc.parser.xml.mock.IMockInterfaceWithGeneric<Int>", "intInstance" );
		var uintInstance = this._getCoreFactory().getInjector().getInstanceWithClassName( "hex.ioc.parser.xml.mock.IMockInterfaceWithGeneric<UInt>", "intInstance" );
		var stringInstance = this._getCoreFactory().getInjector().getInstanceWithClassName( "hex.ioc.parser.xml.mock.IMockInterfaceWithGeneric<String>", "stringInstance" );

		Assert.isInstanceOf( intInstance, MockClassWithGeneric );
		Assert.isInstanceOf( uintInstance, MockClassWithGeneric );
		Assert.isInstanceOf( stringInstance, MockClassWithGeneric );
		
		Assert.equals( intInstance, uintInstance );
		Assert.notEquals( intInstance, stringInstance );
	}
	
	@Test( "test building two modules listening each other" )
	public function testBuildingTwoModulesListeningEachOther() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/twoModulesListeningEachOther.xml" );

		var chat : MockChatModule = this._locate( "chat" );
		Assert.isNotNull( chat, "" );
		Assert.isNull( chat.translatedMessage, "" );

		var translation : MockTranslationModule = this._locate( "translation" );
		Assert.isNotNull( translation, "" );

		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "Hello", chat.translatedMessage, "" );
	}
	
	@Test( "test building two modules listening each other with adapter" )
	public function testBuildingTwoModulesListeningEachOtherWithAdapter() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/twoModulesListeningEachOtherWithAdapter.xml" );

		var chat : MockChatModule = this._locate( "chat" );
		Assert.isNotNull( chat, "" );
		Assert.isNull( chat.translatedMessage, "" );

		var translation : MockTranslationModule = this._locate( "translation" );
		Assert.isNotNull( translation, "" );

		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "Hello", chat.translatedMessage, "" );
		Assert.isInstanceOf( chat.date, Date, "" );
	}
	
	@Test( "test building two modules listening each other with adapter and injection" )
	public function testBuildingTwoModulesListeningEachOtherWithAdapterAndInjection() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/twoModulesListeningEachOtherWithAdapterAndInjection.xml" );

		var chat : MockChatModule = this._locate( "chat" );
		Assert.isNotNull( chat, "" );

		var receiver : MockReceiverModule = this._locate( "receiver" );
		Assert.isNotNull( receiver, "" );

		var parser : MockMessageParserModule = this._locate( "parser" );
		Assert.isNotNull( parser, "" );

		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "BONJOUR", receiver.message, "" );
	}
	
	@Test( "test domain dispatch after module initialisation" )
	public function testDomainDispatchAfterModuleInitialisation() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/domainDispatchAfterModuleInitialisation.xml" );

		var sender : MockSenderModule = this._locate( "sender" );
		Assert.isNotNull( sender, "" );

		var receiver : MockReceiverModule = this._locate( "receiver" );
		Assert.isNotNull( receiver, "" );

		Assert.equals( "hello receiver", receiver.message, "" );
	}
	
	@Test( "test building Map with class reference" )
	public function testBuildingMapWithClassReference() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/hashmapWithClassReference.xml" );

		var map : HashMap<Class<IMockAmazonService>, Class<MockAmazonService>> = this._locate( "map" );
		Assert.isNotNull( map, "" );
		
		var amazonServiceClass : Class<MockAmazonService> = map.get( IMockAmazonService );
		Assert.equals( IMockAmazonService, map.getKeys()[ 0 ], "" );
		Assert.equals( MockAmazonService, amazonServiceClass, "" );
	}
	
	@Test( "test target sub property" )
	public function testTargetSubProperty() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/targetSubProperty.xml" );

		var mockObject : MockObjectWithRegtangleProperty = this._locate( "mockObject" );
		Assert.isInstanceOf( mockObject, MockObjectWithRegtangleProperty );
		Assert.equals( 1.5, mockObject.rectangle.x );
	}
	
	@Test( "test building class reference" )
	public function testBuildingClassReference() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/classReference.xml" );

		var rectangleClass : Class<MockRectangle> = this._locate( "RectangleClass" );
		Assert.isInstanceOf( rectangleClass, Class, "" );
		Assert.isInstanceOf( Type.createInstance( rectangleClass, [] ), MockRectangle, "" );

		var classContainer = this._locate( "classContainer" );

		var anotherRectangleClass : Class<MockRectangle> = classContainer.AnotherRectangleClass;
		Assert.isInstanceOf( anotherRectangleClass, Class, "" );
		Assert.isInstanceOf( Type.createInstance( anotherRectangleClass, [] ), MockRectangle, "" );

		Assert.equals( rectangleClass, anotherRectangleClass, "" );

		var anotherRectangleClassRef : Class<MockRectangle> = this._locate( "classContainer.AnotherRectangleClass" );
		Assert.isInstanceOf( anotherRectangleClassRef, Class, "" );
		Assert.equals( anotherRectangleClass, anotherRectangleClassRef, "" );
	}
	
	@Test( "test building mapping configuration" )
	public function testBuildingMappingConfiguration() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/mappingConfiguration.xml" );

		var config : MappingConfiguration = this._locate( "config" );
		Assert.isInstanceOf( config, MappingConfiguration, "" );

		var injector = new Injector();
		config.configure( injector, new Dispatcher(), null );

		Assert.isInstanceOf( injector.getInstance( IMockAmazonService ), MockAmazonService, "" );
		Assert.isInstanceOf( injector.getInstance( IMockFacebookService ), MockFacebookService, "" );
		Assert.equals( this._locate( "facebookService" ), injector.getInstance( IMockFacebookService ), "" );
	}
	
	@Test( "test building mapping configuration with map names" )
	public function testBuildingMappingConfigurationWithMapNames() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/mappingConfigurationWithMapNames.xml" );

		var config : MappingConfiguration = this._locate( "config" );
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

		var config = this._locate( "config" );
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
	
	@Test( "test building mapping configuration with inject-into" )
	public function testBuildingMappingConfigurationWithInjectInto() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/mappingConfigurationWithInjectInto.xml" );

		var config = this._locate( "config" );
		Assert.isInstanceOf( config, MappingConfiguration, "" );

		var injector = new Injector();
		var domain = DomainUtil.getDomain( 'testBuildingMappingConfigurationWithInjectInto', Domain );
		injector.mapToValue( Domain, domain );
		
		config.configure( injector, new Dispatcher(), null );

		var mock0 = injector.getInstance( IMockInjectee, "mock0" );
		Assert.isInstanceOf( mock0,  MockInjectee, "" );
		Assert.equals( domain, mock0.domain, "" );
		
		var mock1 = injector.getInstance( IMockInjectee, "mock1" );
		Assert.isInstanceOf( mock1, MockInjectee, "" );
		Assert.equals( domain, mock1.domain, "" );
	}
	
	@Test( "test static-ref" )
	public function testStaticRef() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/staticRef.xml" );

		var note : String = this._locate( "constant" );
		Assert.isNotNull( note, "" );
		Assert.equals( note, MockStubStatefulService.INT_VO_UPDATE, "" );
	}
	
	@Test( "test static-ref property" )
	public function testStaticProperty() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/staticRefProperty.xml" );

		var object : Dynamic = this._locate( "object" );
		Assert.isNotNull( object );
		Assert.equals( MockStubStatefulService.INT_VO_UPDATE, object.property );
		
		var object2 : Dynamic = this._locate( "object2" );
		Assert.isNotNull( object2 );
		Assert.equals( MockStubStatefulService, object2.property );
	}
	
	@Test( "test static-ref argument" )
	public function testStaticArgument() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/staticRefArgument.xml" );

		var instance : ClassWithConstantConstantArgument = this._locate( "instance" );
		Assert.isNotNull( instance, "" );
		Assert.equals( instance.constant, MockStubStatefulService.INT_VO_UPDATE, "" );
	}
	
	@Test( "test static-ref argument on method-call" )
	public function testStaticArgumentOnMethodCall() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/staticRefArgumentOnMethodCall.xml" );

		var instance : MockMethodCaller = this._locate( "instance" );
		Assert.isNotNull( instance, "" );
		Assert.equals( MockMethodCaller.staticVar, instance.argument, "" );
	}
	
	@Test( "test map-type attribute" )
	public function testMapTypeAttribute() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/mapTypeAttribute.xml" );

		var myModule : MockMappedModule = this._locate( "myModule" );
		Assert.isNotNull( myModule, "" );
		Assert.isInstanceOf( myModule, MockMappedModule, "" );
		Assert.equals( myModule, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstance( IMockMappedModule, "myModule" ), "" );
	}
	
	@Test( "test multi map-type attributes" )
	public function testMultiMapTypeAttributes() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/multiMapTypeAttributes.xml" );

		var myModule : MockMappedModule = this._locate( "myModule" );
		Assert.isNotNull( myModule, "" );
		Assert.isInstanceOf( myModule, MockMappedModule, "" );
		Assert.isInstanceOf( myModule, IAnotherMockMappedModule, "" );
		
		Assert.equals( myModule, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstance( IMockMappedModule, "myModule" ), "" );
		Assert.equals( myModule, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstance( IAnotherMockMappedModule, "myModule" ), "" );
	}
	
	@Test( "test static-ref with factory" )
	public function testStaticRefWithFactory() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/staticRefFactory.xml" );
		var doc : MockDocument = this._locate( "div" );
		Assert.isNotNull( doc, "" );
		Assert.isInstanceOf( doc, MockDocument, "" );
	}

	@Test( "test module listening service" )
	public function testModuleListeningService() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/moduleListeningService.xml" );

		var myService : IMockStubStatefulService = this._locate( "myService" );
		Assert.isNotNull( myService, "" );

		var myModule : MockModuleWithServiceCallback = this._locate( "myModule" );
		Assert.isNotNull( myModule, "" );

		var booleanVO = new MockBooleanVO( true );
		myService.setBooleanVO( booleanVO );
		Assert.isTrue( myModule.getBooleanValue(), "" );
	}
	
	@Test( "test module listening service with map-type" )
	public function testModuleListeningServiceWithMapType() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/moduleListeningServiceWithMapType.xml" );

		var myService : IMockStubStatefulService = this._locate( "myService" );
		Assert.isNotNull( myService );

		var myModule : MockModuleWithServiceCallback = this._locate( "myModule" );
		Assert.isNotNull( myModule );

		var booleanVO = new MockBooleanVO( true );
		myService.setBooleanVO( booleanVO );
		Assert.isTrue( myModule.getBooleanValue() );
		
		Assert.equals( myService, this._getCoreFactory().getInjector().getInstance( IMockStubStatefulService, "myService" ) );
	}
	
	@Test( "test module listening service with strategy and module injection" )
	public function testModuleListeningServiceWithStrategyAndModuleInjection() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/moduleListeningServiceWithStrategyAndModuleInjection.xml" );

		var myService : IMockStubStatefulService = this._locate( "myService" );
		Assert.isNotNull( myService, "" );

		var myModule : MockModuleWithServiceCallback = this._locate( "myModule" );
		Assert.isNotNull( myModule, "" );

		var intVO = new MockIntVO( 7 );
		myService.setIntVO( intVO );
		Assert.equals( 3.5, ( myModule.getFloatValue() ), "" );
	}
	
	@Test( "test module listening service with strategy and context injection" )
	public function testModuleListeningServiceWithStrategyAndContextInjection() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/moduleListeningServiceWithStrategyAndContextInjection.xml" );

		var mockDividerHelper : IMockDividerHelper = this._locate( "mockDividerHelper" );
		Assert.isNotNull( mockDividerHelper, "" );

		var myService : IMockStubStatefulService = this._locate( "myService" );
		Assert.isNotNull( myService, "" );

		var myModuleA : MockModuleWithServiceCallback = this._locate( "myModuleA" );
		Assert.isNotNull( myModuleA, "" );

		var myModuleB : AnotherMockModuleWithServiceCallback = this._locate( "myModuleB" );
		Assert.isNotNull( myModuleB, "" );

		myService.setIntVO( new MockIntVO( 7 ) );
		Assert.equals( 3.5, ( myModuleA.getFloatValue() ), "" );

		myService.setIntVO( new MockIntVO( 9 ) );
		Assert.equals( 4.5, ( myModuleB.getFloatValue() ), "" );
	}
	
	#if (!neko || haxe_ver >= "3.3")
	@Async( "test EventTrigger" )
	public function testEventTrigger() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/eventTrigger.xml" );

		var eventTrigger : Dynamic = this._locate( "eventTrigger" );
		Assert.isNotNull( eventTrigger, "" );
		
		var chat : MockChatModule = this._locate( "chat" );
		Assert.isNotNull( chat, "" );

		var receiver : MockReceiverModule = this._locate( "receiver" );
		Assert.isNotNull( receiver, "" );

		var parser : MockMessageParserModule = this._locate( "parser" );
		Assert.isNotNull( parser, "" );

		Timer.delay( MethodRunner.asyncHandler( this._onCompleteHandler ), 500 );
		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "bonjour" ] );
	}
	
	@Async( "test EventProxy" )
	public function testEventProxy() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/eventProxy.xml" );

		var eventProxy : EventProxy = this._locate( "eventProxy" );
		Assert.isNotNull( eventProxy, "" );

		var chat : MockChatModule = this._locate( "chat" );
		Assert.isNotNull( chat, "" );

		var receiver : MockReceiverModule = this._locate( "receiver" );
		Assert.isNotNull( receiver, "" );

		var eventProxy : EventProxy = this._locate( "eventProxy" );
		Assert.isNotNull( eventProxy, "" );

		var parser : MockMessageParserModule = this._locate( "parser" );
		Assert.isNotNull( parser, "" );

		Timer.delay( MethodRunner.asyncHandler( this._onCompleteHandler ), 500 );
		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "bonjour" ] );
	}
	
	function _onCompleteHandler() : Void
	{
		var receiver : MockReceiverModule = this._locate( "receiver" );
		Assert.equals( "BONJOUR:HTTP://GOOGLE.COM", receiver.message, "" );
	}
	#end
	
	function getColorByName( name : String ) : Int
	{
		return name == "white" ? 0xFFFFFF : 0;
	}

	function getText( name : String ) : String
	{
		return name == "welcome" ? "Bienvenue" : null;
	}
	
	function getAnotherText( name : String ) : String
	{
		return "anotherText";
	}
	
	@Test( "Test MockObject with annotation" )
	public function testMockObjectWithAnnotation() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/testMockObjectWithAnnotation.xml" );
		
		var annotationProvider : IAnnotationProvider = this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstance( IAnnotationProvider );

		annotationProvider.registerMetaData( "color", this.getColorByName );
		annotationProvider.registerMetaData( "language", this.getText );
		
		var mockObjectWithMetaData = this._locate( "mockObjectWithAnnotation" );
		
		Assert.equals( 0xffffff, mockObjectWithMetaData.colorTest, "color should be the same" );
		Assert.equals( "Bienvenue", mockObjectWithMetaData.languageTest, "text should be the same" );
		Assert.isNull( mockObjectWithMetaData.propWithoutMetaData, "property should be null" );
	}
	
	@Test( "Test AnnotationProvider with inheritance" )
	public function testAnnotationProviderWithInheritance() : Void
	{
		var assembler = new ApplicationAssembler();
		this._applicationAssembler = assembler;
		
		XmlCompiler.readXmlFileWithAssembler( assembler, "context/testMockObjectWithAnnotation.xml" );
		
		var annotationProvider : IAnnotationProvider = this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstance( IAnnotationProvider );
		annotationProvider.registerMetaData( "color", this.getColorByName );
		annotationProvider.registerMetaData( "language", this.getText );
		
		XmlCompiler.readXmlFileWithAssembler( assembler, "context/testAnnotationProviderWithInheritance.xml" );
		
		var mockObjectWithMetaData = this._locate( "mockObjectWithAnnotation" );
		
		Assert.equals( 0xffffff, mockObjectWithMetaData.colorTest, "color should be the same" );
		Assert.equals( "Bienvenue", mockObjectWithMetaData.languageTest, "text should be the same" );
		Assert.isNull( mockObjectWithMetaData.propWithoutMetaData, "property should be null" );
		
		//
		var module : MockModuleWithAnnotationProviding = this._locate( "module" );
		var provider = module.getAnnotationProvider();
		module.buildComponents();

		Assert.equals( 0xffffff, module.mockObjectWithMetaData.colorTest, "color should be the same" );
		Assert.equals( "Bienvenue", module.mockObjectWithMetaData.languageTest, "text should be the same" );
		Assert.isNull( module.anotherMockObjectWithMetaData.languageTest, "property should be null when class is not implementing IAnnotationParsable" );
		
		provider.registerMetaData( "language", this.getAnotherText );
		module.buildComponents();
		
		Assert.equals( 0xffffff, module.mockObjectWithMetaData.colorTest, "color should be the same" );
		Assert.equals( "anotherText", module.mockObjectWithMetaData.languageTest, "text should be the same" );
		Assert.isNull( module.anotherMockObjectWithMetaData.languageTest, "property should be null when class is not implementing IAnnotationParsable" );
	}
	
	@Test( "Test Macro with annotation" )
	public function testMacroWithAnnotation() : Void
	{
		MockMacroWithAnnotation.lastResult = null;
		MockCommandWithAnnotation.lastResult = null;
		MockAsyncCommandWithAnnotation.lastResult = null;
		
		var applicationAssembler = new ApplicationAssembler();
        var applicationContext = applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext );
        var injector = applicationContext.getInjector();
        
        var annotationProvider = AnnotationProvider.getAnnotationProvider( applicationContext.getDomain() );
        annotationProvider.registerMetaData( "Value", this._getValue );
		
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/macroWithAnnotation.xml" );
		
		var annotationProvider : IAnnotationProvider = this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstance( IAnnotationProvider );

		Assert.equals( "value", MockMacroWithAnnotation.lastResult, "text should be the same" );
		Assert.equals( "value", MockCommandWithAnnotation.lastResult, "text should be the same" );
		Assert.equals( "value", MockAsyncCommandWithAnnotation.lastResult, "text should be the same" );
	}

	function _getValue( key : String ) return "value";
		
	
	@Test( "test if attribute" )
	public function testIfAttribute() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/ifAttribute.xml", null, [ "production" => true, "test" => false, "release" => false ] );
		Assert.equals( "hello production", this._locate( "message" ), "message value should equal 'hello production'" );
	}
	
	@Test( "test include with if attribute" )
	public function testIncludeWithIfAttribute() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/includeWithIfAttribute.xml", null, [ "production" => true, "test" => false, "release" => false ] );
		Assert.equals( "hello production", this._locate( "message" ), "message value should equal 'hello production'" );
	}
	
	@Test( "test include fails with if attribute" )
	public function testIncludeFailsWithIfAttribute() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/includeWithIfAttribute.xml", null, [ "production" => false, "test" => true, "release" => true ] );
		Assert.methodCallThrows( NoSuchElementException, this._getCoreFactory(), this._locate, [ "message" ], "'NoSuchElementException' should be thrown" );
	}
	
	@Test( "test file preprocessor with Xml file" )
	public function testFilePreprocessorWithXmlFile() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/preprocessor.xml", [	"hello" 		=> "bonjour",
																					"contextName" 	=> 'applicationContext',
																					"context" 		=> 'name="${contextName}"',
																					"node" 			=> '<msg id="message" value="${hello}"/>' ] );

		Assert.equals( "bonjour", this._locate( "message" ), "message value should equal 'bonjour'" );
	}
	
	@Test( "test file preprocessor with Xml file and include" )
	public function testFilePreprocessorWithXmlFileAndInclude() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/preprocessorWithInclude.xml", [	"hello" 		=> "bonjour",
																					"contextName" 	=> 'applicationContext',
																					"context" 		=> 'name="${contextName}"',
																					"node" 			=> '<msg id="message" value="${hello}"/>' ] );

		try
        {
			Assert.equals( "bonjour", this._locate( "message" ), "message value should equal 'bonjour'" );
		}
		catch ( e : Exception )
        {
            Assert.fail( e.message, "Exception on this._builderFactory.getCoreFactory().locate( \"message\" ) call" );
        }
	}
}