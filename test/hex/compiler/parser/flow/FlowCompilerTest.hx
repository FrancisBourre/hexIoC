package hex.compiler.parser.flow;

import hex.collection.HashMap;
import hex.compiler.parser.flow.FlowCompiler;
import hex.core.IApplicationAssembler;
import hex.core.ICoreFactory;
import hex.di.IDependencyInjector;
import hex.di.Injector;
import hex.di.mapping.MappingChecker;
import hex.di.mapping.MappingConfiguration;
import hex.domain.ApplicationDomainDispatcher;
import hex.error.NoSuchElementException;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.core.ContextFactory;
import hex.ioc.parser.xml.ApplicationXMLParser;
import hex.ioc.parser.xml.mock.MockChatModule;
import hex.ioc.parser.xml.mock.MockTranslationModule;
import hex.mock.AnotherMockClass;
import hex.mock.ArrayOfDependenciesOwner;
import hex.mock.ClassWithConstantConstantArgument;
import hex.mock.IAnotherMockInterface;
import hex.mock.IMockInterface;
import hex.mock.MockCaller;
import hex.mock.MockChat;
import hex.mock.MockClass;
import hex.mock.MockClassWithGeneric;
import hex.mock.MockClassWithInjectedProperty;
import hex.mock.MockClassWithoutArgument;
import hex.mock.MockContextHolder;
import hex.mock.MockFruitVO;
import hex.mock.MockMethodCaller;
import hex.mock.MockProxy;
import hex.mock.MockReceiver;
import hex.mock.MockRectangle;
import hex.mock.MockServiceProvider;
import hex.runtime.ApplicationAssembler;
import hex.structures.Point;
import hex.structures.Size;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class FlowCompilerTest 
{
	var _contextFactory 			: ContextFactory;
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
	
	@Test( "test context reference" )
	public function testContextReference() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/contextReference.flow" );
		var contextHolder : MockContextHolder = this._getCoreFactory().locate( "contextHolder" );
		var context = this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext );
		Assert.equals( context, contextHolder.context );
	}
	
	@Test( "test building String with assembler" )
	public function testBuildingStringWithAssembler() : Void
	{
		var assembler = new ApplicationAssembler();
		assembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory().register( "s2", "bonjour" );
		
		this._applicationAssembler = FlowCompiler.compileWithAssembler( assembler, "context/flow/primitives/string.flow" );

		Assert.equals( "hello", this._getCoreFactory().locate( "s" ) );
		Assert.equals( "bonjour", this._getCoreFactory().locate( "s2" ) );
		Assert.equals( assembler, this._applicationAssembler );
	}
	
	@Test( "test building String instances with the same assembler at compile time and runtime" )
	public function testBuildingStringsMixingCompileTimeAndRuntime() : Void
	{
		var assembler = new ApplicationAssembler();
		ApplicationXMLParser.parseString( assembler, '<root name="applicationContext"><test id="s2" value="hola"/></root>' );
		this._applicationAssembler = FlowCompiler.compileWithAssembler( assembler, "context/flow/primitives/string.flow" );

		Assert.equals( "hello", this._getCoreFactory().locate( "s" ) );
		Assert.equals( "hola", this._getCoreFactory().locate( "s2" ) );
		Assert.equals( assembler, this._applicationAssembler );
	}
	
	@Test( "test building String" )
	public function testBuildingString() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/primitives/string.flow" );
		var s : String = this._getCoreFactory().locate( "s" );
		Assert.equals( "hello", s );
	}
	
	@Test( "test building String with assembler property" )
	public function testBuildingStringWithAssemblerProperty() : Void
	{
		this._applicationAssembler = new ApplicationAssembler();
		FlowCompiler.compileWithAssembler( this._applicationAssembler, "context/flow/primitives/string.flow" );
		var s : String = this._getCoreFactory().locate( "s" );
		Assert.equals( "hello", s );
	}
	
	@Ignore( "test building String with assembler static property" )
	public function testBuildingStringWithAssemblerStaticProperty() : Void
	{
		FlowCompilerTest.applicationAssembler = new ApplicationAssembler();
		FlowCompiler.compileWithAssembler( FlowCompilerTest.applicationAssembler, "context/flow/primitives/string.flow" );
		var s : String = this._getCoreFactory().locate( "s" );
		Assert.equals( "hello", s );
	}
	
	@Test( "test read twice the same context" )
	public function testReadTwiceTheSameContext() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		this._applicationAssembler = new ApplicationAssembler();
		
		FlowCompiler.compileWithAssembler( applicationAssembler, "context/flow/simpleInstanceWithoutArguments.flow" );
		FlowCompiler.compileWithAssembler( this._applicationAssembler, "context/flow/simpleInstanceWithoutArguments.flow" );
		
		var localCoreFactory = applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory();

		var instance1 = localCoreFactory.locate( "instance" );
		Assert.isInstanceOf( instance1, MockClassWithoutArgument );
		
		var instance2 = this._getCoreFactory().locate( "instance" );
		Assert.isInstanceOf( instance2, MockClassWithoutArgument );
		
		Assert.notEquals( instance1, instance2 );
	}
	
	@Test( "test overriding context name" )
	public function testOverridingContextName() : Void
	{
		this._applicationAssembler = new ApplicationAssembler();
		
		FlowCompiler.compileWithAssembler( this._applicationAssembler, "context/flow/simpleInstanceWithoutArguments.flow", 'name1' );
		FlowCompiler.compileWithAssembler( this._applicationAssembler, "context/flow/simpleInstanceWithoutArguments.flow", 'name2' );
		
		var factory1 = this._applicationAssembler.getApplicationContext( "name1", ApplicationContext ).getCoreFactory();
		var factory2 = this._applicationAssembler.getApplicationContext( "name2", ApplicationContext ).getCoreFactory();

		var instance1 = factory1.locate( "instance" );
		Assert.isInstanceOf( instance1, MockClassWithoutArgument );
		
		var instance2 = factory2.locate( "instance" );
		Assert.isInstanceOf( instance2, MockClassWithoutArgument );
		
		Assert.notEquals( instance1, instance2 );
	}
	
	@Test( "test building Int" )
	public function testBuildingInt() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/primitives/int.flow" );
		var i : Int = this._getCoreFactory().locate( "i" );
		Assert.equals( -3, i );
	}
	
	@Test( "test building Hex" )
	public function testBuildingHex() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/primitives/hex.flow" );
		Assert.equals( 0xFFFFFF, this._getCoreFactory().locate( "i" ) );
	}
	
	@Test( "test building Bool" )
	public function testBuildingBool() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/primitives/bool.flow" );
		var b : Bool = this._getCoreFactory().locate( "b" );
		Assert.isTrue( b );
	}
	
	@Test( "test building UInt" )
	public function testBuildingUInt() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/primitives/uint.flow" );
		var i : UInt = this._getCoreFactory().locate( "i" );
		Assert.equals( 3, i );
	}
	
	@Test( "test building Float" )
	public function testBuildingFloat() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/primitives/float.flow" );
		var f : Float = this._getCoreFactory().locate( "f" );
		Assert.equals( -12.5, f );
	}
	
	@Test( "test building null" )
	public function testBuildingNull() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/primitives/null.flow" );
		var result = this._getCoreFactory().locate( "value" );
		Assert.isNull( result );
	}
	
	@Test( "test building anonymous object" )
	public function testBuildingAnonymousObject() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/anonymousObject.flow" );
		var obj : Dynamic = this._getCoreFactory().locate( "obj" );

		Assert.equals( "Francis", obj.name );
		Assert.equals( 44, obj.age );
		Assert.equals( 1.75, obj.height );
		Assert.isTrue( obj.isWorking );
		Assert.isFalse( obj.isSleeping );
		Assert.equals( 1.75, this._getCoreFactory().locate( "obj.height" ) );
	}
	
	@Test( "test building simple instance without arguments" )
	public function testBuildingSimpleInstanceWithoutArguments() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/simpleInstanceWithoutArguments.flow" );

		var instance : MockClassWithoutArgument = this._getCoreFactory().locate( "instance" );
		Assert.isInstanceOf( instance, MockClassWithoutArgument );
	}
	
	@Test( "test building simple instance with arguments" )
	public function testBuildingSimpleInstanceWithArguments() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/simpleInstanceWithArguments.flow" );

		var size : Size = this._getCoreFactory().locate( "size" );
		Assert.isInstanceOf( size, Size );
		Assert.equals( 10, size.width );
		Assert.equals( 20, size.height );
	}
	
	@Test( "test building multiple instances with arguments" )
	public function testBuildingMultipleInstancesWithArguments() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/multipleInstancesWithArguments.flow" );

		var size : Size = this._getCoreFactory().locate( "size" );
		Assert.isInstanceOf( size, Size );
		Assert.equals( 15, size.width );
		Assert.equals( 25, size.height );

		var position : Point = this._getCoreFactory().locate( "position" );
		Assert.equals( 35, position.x );
		Assert.equals( 45, position.y );
	}
	
	@Test( "test building single instance with primitives references" )
	public function testBuildingSingleInstanceWithPrimitivesReferences() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/singleInstanceWithPrimReferences.flow" );
		
		var x : Int = this._getCoreFactory().locate( "x" );
		Assert.equals( 1, x );
		
		var y : Int = this._getCoreFactory().locate( "y" );
		Assert.equals( 2, y );

		var position : Point = this._getCoreFactory().locate( "position" );
		Assert.equals( 1, position.x );
		Assert.equals( 2, position.y );
	}
	
	@Test( "test building single instance with method references" )
	public function testBuildingSingleInstanceWithMethodReferences() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/singleInstanceWithMethodReferences.flow" );
		
		var chat : MockChat = this._getCoreFactory().locate( "chat" );
		Assert.isInstanceOf( chat, MockChat );
		
		var receiver : MockReceiver = this._getCoreFactory().locate( "receiver" );
		Assert.isInstanceOf( receiver, MockReceiver );
		
		var proxyChat : MockProxy = this._getCoreFactory().locate( "proxyChat" );
		Assert.isInstanceOf( proxyChat, MockProxy );
		
		var proxyReceiver : MockProxy = this._getCoreFactory().locate( "proxyReceiver" );
		Assert.isInstanceOf( proxyReceiver, MockProxy );

		Assert.equals( chat, proxyChat.scope );
		Assert.equals( chat.onTranslation, proxyChat.callback );
		
		Assert.equals( receiver, proxyReceiver.scope );
		Assert.equals( receiver.onMessage, proxyReceiver.callback );
	}
	
	@Test( "test building multiple instances with references" )
	public function testAssignInstancePropertyWithReference() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/instancePropertyWithReference.flow" );
		
		var width : Int = this._getCoreFactory().locate( "width" );
		Assert.equals( 10, width );
		
		var height : Int = this._getCoreFactory().locate( "height" );
		Assert.equals( 20, height );
		
		var size : Point = this._getCoreFactory().locate( "size" );
		Assert.equals( width, size.x );
		Assert.equals( height, size.y );
		
		var rect : MockRectangle = this._getCoreFactory().locate( "rect" );
		Assert.equals( width, rect.size.x );
		Assert.equals( height, rect.size.y );
	}
	
	@Test( "test building multiple instances with references" )
	public function testBuildingMultipleInstancesWithReferences() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/multipleInstancesWithReferences.flow" );

		var rectSize : Point = this._getCoreFactory().locate( "rectSize" );
		Assert.equals( 30, rectSize.x );
		Assert.equals( 40, rectSize.y );

		var rectPosition : Point = this._getCoreFactory().locate( "rectPosition" );
		Assert.equals( 10, rectPosition.x );
		Assert.equals( 20, rectPosition.y );

		var rect : MockRectangle = this._getCoreFactory().locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle );
		Assert.equals( 10, rect.x );
		Assert.equals( 20, rect.y );
		Assert.equals( 30, rect.size.x );
		Assert.equals( 40, rect.size.y );
	}
	
	@Test( "test simple method call" )
	public function testSimpleMethodCall() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/simpleMethodCall.flow" );

		var caller : MockCaller = this._getCoreFactory().locate( "caller" );
		Assert.isInstanceOf( caller, MockCaller );
		Assert.deepEquals( [ "hello", "world" ], MockCaller.passedArguments );
	}
	
	@Test( "test method call with type params" )
	public function testCallWithTypeParams() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/methodCallWithTypeParams.flow" );

		var caller : MockCaller = this._getCoreFactory().locate( "caller" );
		Assert.isInstanceOf( caller, MockCaller, "" );
		Assert.equals( 3, MockCaller.passedArray.length, "" );
	}
	
	@Test( "test building multiple instances with method calls" )
	public function testBuildingMultipleInstancesWithMethodCall() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/multipleInstancesWithMethodCall.flow" );

		var rectSize : Point = this._getCoreFactory().locate( "rectSize" );
		Assert.equals( 30, rectSize.x );
		Assert.equals( 40, rectSize.y );

		var rectPosition : Point = this._getCoreFactory().locate( "rectPosition" );
		Assert.equals( 10, rectPosition.x );
		Assert.equals( 20, rectPosition.y );


		var rect : MockRectangle = this._getCoreFactory().locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle );
		Assert.equals( 10, rect.x );
		Assert.equals( 20, rect.y );
		Assert.equals( 30, rect.width );
		Assert.equals( 40, rect.height );

		var anotherRect : MockRectangle = this._getCoreFactory().locate( "anotherRect" );
		Assert.isInstanceOf( anotherRect, MockRectangle );
		Assert.equals( 0, anotherRect.x );
		Assert.equals( 0, anotherRect.y );
		Assert.equals( 0, anotherRect.width );
		Assert.equals( 0, anotherRect.height );
	}
	
	
	@Test( "test building instance with static method" )
	public function testBuildingInstanceWithStaticMethod() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/instanceWithStaticMethod.flow" );

		var service : MockServiceProvider = this._getCoreFactory().locate( "service" );
		Assert.isInstanceOf( service, MockServiceProvider );
		Assert.equals( "http://localhost/amfphp/gateway.php", MockServiceProvider.getInstance().getGateway(), "" );
	}
	
	@Test( "test building instance with static method and arguments" )
	public function testBuildingInstanceWithStaticMethodAndArguments() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/instanceWithStaticMethodAndArguments.flow" );

		var rect : MockRectangle = this._getCoreFactory().locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle );
		Assert.equals( 10, rect.x );
		Assert.equals( 20, rect.y );
		Assert.equals( 30, rect.width );
		Assert.equals( 40, rect.height );
	}
	
	@Test( "test building instance with static method and factory method" )
	public function testBuildingInstanceWithStaticMethodAndFactoryMethod() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/instanceWithStaticMethodAndFactoryMethod.flow" );
		var point : Point = this._getCoreFactory().locate( "point" );

		Assert.equals( 10, point.x );
		Assert.equals( 20, point.y );
	}
	
	@Test( "test 'inject-into' attribute" )
	public function testInjectIntoAttribute() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/injectIntoAttribute.flow" );

		var instance : MockClassWithInjectedProperty = this._getCoreFactory().locate( "instance" );
		Assert.isInstanceOf( instance, MockClassWithInjectedProperty, "" );
		Assert.equals( "hola mundo", instance.property, "" );
		Assert.isTrue( instance.postConstructWasCalled, "" );
	}
	
	@Test( "test building XML without parser class" )
	public function testBuildingXMLWithoutParserClass() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/xmlWithoutParserClass.flow" );

		var fruits : Xml = this._getCoreFactory().locate( "fruits" );
		Assert.isNotNull( fruits );
		Assert.isInstanceOf( fruits, Xml );
	}
	
	@Test( "test building XML with parser class" )
	public function testBuildingXMLWithParserClass() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/xmlWithParserClass.flow" );

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
		this._applicationAssembler = FlowCompiler.compile( "context/flow/arrayFilledWithReferences.flow" );
		
		var text : Array<String> = this._getCoreFactory().locate( "text" );
		Assert.equals( 2, text.length );
		Assert.equals( "hello", text[ 0 ] );
		Assert.equals( "world", text[ 1 ] );
		
		var empty : Array<String> = this._getCoreFactory().locate( "empty" );
		Assert.equals( 0, empty.length );

		var fruits : Array<MockFruitVO> = this._getCoreFactory().locate( "fruits" );
		Assert.equals( 3, fruits.length, "" );

		var orange 	: MockFruitVO = fruits[0];
		var apple 	: MockFruitVO = fruits[1];
		var banana 	: MockFruitVO = fruits[2];

		Assert.equals( "orange", orange.toString()  );
		Assert.equals( "apple", apple.toString() );
		Assert.equals( "banana", banana.toString() );
	}
	
	@Test( "test building Map filled with references" )
	public function testBuildingMapFilledWithReferences() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/hashmapFilledWithReferences.flow" );

		var fruits : HashMap<Any, MockFruitVO> = this._getCoreFactory().locate( "fruits" );
		Assert.isNotNull( fruits );

		var stubKey : Point = this._getCoreFactory().locate( "stubKey" );
		Assert.isNotNull( stubKey );

		var orange 	: MockFruitVO = fruits.get( '0' );
		var apple 	: MockFruitVO = fruits.get( 1 );
		var banana 	: MockFruitVO = fruits.get( stubKey );

		Assert.equals( "orange", orange.toString() );
		Assert.equals( "apple", apple.toString() );
		Assert.equals( "banana", banana.toString() );
	}

	@Test( "test building HashMap with map-type" )
	public function testBuildingHashMapWithMapType() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/hashmapWithMapType.flow" );

		var fruits : HashMap<Any, MockFruitVO> = this._getCoreFactory().locate( "fruits" );
		Assert.isNotNull( fruits, "" );

		var orange 	: MockFruitVO = fruits.get( '0' );
		var apple 	: MockFruitVO = fruits.get( '1' );

		Assert.equals( "orange", orange.toString(), "" );
		Assert.equals( "apple", apple.toString(), "" );
		
		var map = this._getCoreFactory().getInjector().getInstanceWithClassName( "hex.collection.HashMap<String,hex.mock.MockFruitVO>", "fruits" );
		Assert.equals( fruits, map );
	}
	
	@Test( "test map-type attribute with Array" )
	public function testMapTypeWithArray() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/mapTypeWithArray.flow" );
		
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
		this._applicationAssembler = FlowCompiler.compile( "context/flow/mapTypeWithInstance.flow" );
		
		var intInstance = this._getCoreFactory().getInjector().getInstanceWithClassName( "hex.mock.IMockInterfaceWithGeneric<Int>", "intInstance" );
		var uintInstance = this._getCoreFactory().getInjector().getInstanceWithClassName( "hex.mock.IMockInterfaceWithGeneric<UInt>", "intInstance" );
		var stringInstance = this._getCoreFactory().getInjector().getInstanceWithClassName( "hex.mock.IMockInterfaceWithGeneric<String>", "stringInstance" );

		Assert.isInstanceOf( intInstance, MockClassWithGeneric );
		Assert.isInstanceOf( uintInstance, MockClassWithGeneric );
		Assert.isInstanceOf( stringInstance, MockClassWithGeneric );
		
		Assert.equals( intInstance, uintInstance );
		Assert.notEquals( intInstance, stringInstance );
	}
	
	@Test( "test building two modules listening each other" )
	public function testBuildingTwoModulesListeningEachOther() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/twoModulesListeningEachOther.flow" );

		var chat : MockChatModule = this._getCoreFactory().locate( "chat" );
		Assert.isNotNull( chat, "" );
		Assert.isNull( chat.translatedMessage, "" );

		var translation : MockTranslationModule = this._getCoreFactory().locate( "translation" );
		Assert.isNotNull( translation, "" );

		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "Hello", chat.translatedMessage, "" );
	}
	
	@Test( "test building two modules listening each other with adapter" )
	public function testBuildingTwoModulesListeningEachOtherWithAdapter() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/twoModulesListeningEachOtherWithAdapter.flow" );

		var chat : MockChatModule = this._getCoreFactory().locate( "chat" );
		Assert.isNotNull( chat, "" );
		Assert.isNull( chat.translatedMessage, "" );

		var translation : MockTranslationModule = this._getCoreFactory().locate( "translation" );
		Assert.isNotNull( translation, "" );

		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "Hello", chat.translatedMessage, "" );
		Assert.isInstanceOf( chat.date, Date, "" );
	}
	
	@Test( "test building two modules listening each other with adapter and injection" )
	public function testBuildingTwoModulesListeningEachOtherWithAdapterAndInjection() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/twoModulesListeningEachOtherWithAdapterAndInjection.flow" );

		var chat : MockChatModule = this._getCoreFactory().locate( "chat" );
		Assert.isNotNull( chat, "" );

		var receiver : hex.ioc.parser.xml.mock.MockReceiverModule = this._getCoreFactory().locate( "receiver" );
		Assert.isNotNull( receiver, "" );

		var parser : hex.ioc.parser.xml.mock.MockMessageParserModule = this._getCoreFactory().locate( "parser" );
		Assert.isNotNull( parser, "" );

		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "BONJOUR", receiver.message, "" );
	}
	
	/*@Ignore( "test domain dispatch after module initialisation" )
	public function testDomainDispatchAfterModuleInitialisation() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/domainDispatchAfterModuleInitialisation.xml" );

		var sender : MockSenderModule = this._getCoreFactory().locate( "sender" );
		Assert.isNotNull( sender, "" );

		var receiver : MockReceiverModule = this._getCoreFactory().locate( "receiver" );
		Assert.isNotNull( receiver, "" );

		Assert.equals( "hello receiver", receiver.message, "" );
	}
	
	@Ignore( "test building Map with class reference" )
	public function testBuildingMapWithClassReference() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/hashmapWithClassReference.xml" );

		var map : HashMap<Class<IMockAmazonService>, Class<MockAmazonService>> = this._getCoreFactory().locate( "map" );
		Assert.isNotNull( map, "" );
		
		var amazonServiceClass : Class<MockAmazonService> = map.get( IMockAmazonService );
		Assert.equals( IMockAmazonService, map.getKeys()[ 0 ], "" );
		Assert.equals( MockAmazonService, amazonServiceClass, "" );
	}
	*/
	
	@Test( "test building class reference" )
	public function testBuildingClassReference() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/classReference.flow" );

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
		this._applicationAssembler = FlowCompiler.compile( "context/flow/mappingConfiguration.flow" );

		var config : MappingConfiguration = this._getCoreFactory().locate( "config" );
		Assert.isInstanceOf( config, MappingConfiguration );

		var injector = new Injector();
		config.configure( injector, null );

		Assert.isInstanceOf( injector.getInstance( IMockInterface ), MockClass );
		Assert.isInstanceOf( injector.getInstance( IAnotherMockInterface ), AnotherMockClass );
		Assert.equals( this._getCoreFactory().locate( "instance" ), injector.getInstance( IAnotherMockInterface ) );
	}
	
	/*
	@Ignore( "test building mapping configuration with map names" )
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
	
	@Ignore( "test building mapping configuration with singleton" )
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
	
	@Ignore( "test building mapping configuration with inject-into" )
	public function testBuildingMappingConfigurationWithInjectInto() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/mappingConfigurationWithInjectInto.xml" );

		var config = this._getCoreFactory().locate( "config" );
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
	}*/
	
	@Test( "test static-ref" )
	public function testStaticRef() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/staticRef.flow" );

		var messageType : String = this._getCoreFactory().locate( "constant" );
		Assert.isNotNull( messageType );
		Assert.equals( messageType, MockClass.MESSAGE_TYPE );
	}
	
	@Test( "test static-ref property" )
	public function testStaticProperty() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/staticRefProperty.flow" );

		var object : Dynamic = this._getCoreFactory().locate( "object" );
		Assert.isNotNull( object );
		Assert.equals( MockClass.MESSAGE_TYPE, object.property );
		
		var object2 : Dynamic = this._getCoreFactory().locate( "object2" );
		Assert.isNotNull( object2 );
		Assert.equals( MockClass, object2.property );
	}
	
	@Test( "test static-ref argument" )
	public function testStaticArgument() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/staticRefArgument.flow" );

		var instance : ClassWithConstantConstantArgument = this._getCoreFactory().locate( "instance" );
		Assert.isNotNull( instance, "" );
		Assert.equals( instance.constant, MockClass.MESSAGE_TYPE );
	}
	
	@Test( "test static-ref argument on method-call" )
	public function testStaticArgumentOnMethodCall() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/staticRefArgumentOnMethodCall.flow" );

		var instance : MockMethodCaller = this._getCoreFactory().locate( "instance" );
		Assert.isNotNull( instance, "" );
		Assert.equals( MockMethodCaller.staticVar, instance.argument );
	}
	
	@Test( "test map-type attribute" )
	public function testMapTypeAttribute() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/mapTypeAttribute.flow" );

		var instance : MockClass = this._getCoreFactory().locate( "instance" );
		Assert.isNotNull( instance );
		Assert.isInstanceOf( instance, MockClass );
		Assert.isInstanceOf( instance, IMockInterface );
		Assert.equals( instance, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstance( IMockInterface, "instance" ) );

		var instance2 : MockClass = this._getCoreFactory().locate( "instance2" );
		Assert.isNotNull( instance2 );
		Assert.isInstanceOf( instance2, MockClass );
		Assert.equals( instance2, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstanceWithClassName( "hex.mock.MockModuleWithInternalType.GetInfosInternalTypedef", "instance2" ) );
	}
	
	@Test( "test multi map-type attributes" )
	public function testMultiMapTypeAttributes() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/multiMapTypeAttributes.flow" );

		var instance : MockClass = this._getCoreFactory().locate( "instance" );
		Assert.isNotNull( instance );
		Assert.isInstanceOf( instance, MockClass );
		Assert.isInstanceOf( instance, IMockInterface );
		Assert.isInstanceOf( instance, IAnotherMockInterface );
		
		Assert.equals( instance, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstance( IMockInterface, "instance" ) );
		Assert.equals( instance, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstance( IAnotherMockInterface, "instance" ) );
	}
	
	/*@Ignore( "test static-ref with factory" )
	public function testStaticRefWithFactory() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/staticRefFactory.flow" );
		var doc : MockDocument = this._getCoreFactory().locate( "div" );
		Assert.isNotNull( doc );
		Assert.isInstanceOf( doc, MockDocument );
	}*/
	
	@Test( "test file preprocessor with flow file" )
	public function testFilePreprocessorWithFlowFile() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/preprocessor.flow", 
															[	"hello" 		=> "bonjour",
																"contextName" 	=> 'applicationContext',
																"context" 		=> 'name="${contextName}"',
																"node" 			=> 'message = "${hello}"' ] );

		Assert.equals( "bonjour", this._getCoreFactory().locate( "message" ), "message value should equal 'bonjour'" );
	}
	
	@Test( "test if attribute" )
	public function testIfAttribute() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/ifAttribute.flow", null, null, [ "prodz" => true, "testing" => false, "releasing" => false ] );
		Assert.equals( "hello prod", this._getCoreFactory().locate( "message" ), "message value should equal 'hello prod'" );
	}

	
	@Test( "test include with if attribute" )
	public function testIncludeWithIfAttribute() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/includeWithIfAttribute.flow", null, null, [ "prodz" => true, "testing" => false, "releasing" => false ] );
		Assert.equals( "hello prod", this._getCoreFactory().locate( "message" ), "message value should equal 'hello prod'" );
	}

	@Test( "test include fails with if attribute" )
	public function testIncludeFailsWithIfAttribute() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/includeWithIfAttribute.flow", null, null, [ "prodz" => false, "testing" => true, "releasing" => true ] );
		Assert.methodCallThrows( NoSuchElementException, this._getCoreFactory(), this._getCoreFactory().locate, [ "message" ], "'NoSuchElementException' should be thrown" );
	}

	@Test( "test array recursivity" )
	public function testArrayRecursivity() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/arrayRecursivity.flow" );
		
		var test = this._getCoreFactory().locate( "test" );
		Assert.isInstanceOf( test[ 0 ] , Array );
		Assert.isInstanceOf( test[ 1 ] , Array );
		Assert.isInstanceOf( test[ 2 ] , Array );
		Assert.isInstanceOf( test[0][0], hex.mock.MockClassWithIntGeneric );
		Assert.isInstanceOf( test[1][0], hex.mock.MockClassWithIntGeneric );
		Assert.isInstanceOf( test[2][0], hex.mock.MockClassWithIntGeneric );
		Assert.equals( 1, test[0][0].property );
		Assert.equals( 2, test[1][0].property );
		Assert.equals( 3, test[2][0].property );
		
		var a = cast test[ 3 ];
		Assert.isInstanceOf( a[ 0 ] , hex.mock.MockClassWithIntGeneric );
		Assert.equals( 4, a[ 0 ].property );
		Assert.isInstanceOf( a[ 1 ] , hex.mock.MockClassWithIntGeneric );
		Assert.equals( 5, a[ 1 ].property );
	}
	
	@Test( "test array recursivity with new" )
	public function testArrayRecursivityWithNew() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/arrayRecursivityWithNew.flow" );
		
		var test = this._getCoreFactory().locate( "test" );
		Assert.isInstanceOf( test[ 0 ] , Array );
		Assert.isInstanceOf( test[ 1 ] , Array );
		Assert.isInstanceOf( test[ 2 ] , Array );
		Assert.isInstanceOf( test[0][0], hex.mock.MockClassWithIntGeneric );
		Assert.isInstanceOf( test[1][0], hex.mock.MockClassWithIntGeneric );
		Assert.isInstanceOf( test[2][0], hex.mock.MockClassWithIntGeneric );
		Assert.equals( 1, test[0][0].property );
		Assert.equals( 2, test[1][0].property );
		Assert.equals( 3, test[2][0].property );
		
		var a = cast test[ 3 ];
		Assert.isInstanceOf( a[ 0 ] , hex.mock.MockClassWithIntGeneric );
		Assert.equals( 4, a[ 0 ].property );
		Assert.equals( 5, a[ 1 ] );
	}
	
	@Test( "test array recursivity with new mixed with brackets" )
	public function testArrayRecursivityWithNewMixedWithBrackets() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/arrayRecursivityWithNewMixedWithBrackets.flow" );
		
		var test = this._getCoreFactory().locate( "test" );
		Assert.isInstanceOf( test[ 0 ] , Array );
		Assert.isInstanceOf( test[ 1 ] , Array );
		Assert.isInstanceOf( test[ 2 ] , Array );
		Assert.isInstanceOf( test[0][0], hex.mock.MockClassWithIntGeneric );
		Assert.isInstanceOf( test[1][0], hex.mock.MockClassWithIntGeneric );
		Assert.isInstanceOf( test[2][0], hex.mock.MockClassWithIntGeneric );
		Assert.equals( 1, test[0][0].property );
		Assert.equals( 2, test[1][0].property );
		Assert.equals( 3, test[2][0].property );
		
		var a = cast test[ 3 ];
		Assert.isInstanceOf( a[ 0 ] , hex.mock.MockClassWithIntGeneric );
		Assert.equals( 4, a[ 0 ].property );
		Assert.equals( 5, a[ 1 ] );
	}
	
	@Test( "test new recursivity" )
	public function testNewRecursivity() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/newRecursivity.flow" );
		
		var test = this._getCoreFactory().locate( "test" );
		Assert.isInstanceOf( test, hex.mock.MockContextHolder );
		Assert.isInstanceOf( test.context, hex.mock.MockApplicationContext );
	}
	
	@Test( "test dependencies checking" )
	public function testDependenciesChecking() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/static/dependencies.flow" );
	}
	
	@Test( "test array of dependencies checking" )
	public function testArrayOfDependenciesChecking() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/static/arrayOfDependencies.flow" );

		var mappings1 = this._getCoreFactory().locate( "mappings1" );
		var mappings2 = this._getCoreFactory().locate( "mappings2" );
		
		Assert.isTrue( MappingChecker.match( ArrayOfDependenciesOwner, mappings1 ) );
		Assert.isTrue( MappingChecker.match( ArrayOfDependenciesOwner, mappings2 ) );
		Assert.deepEquals( mappings1, mappings2 );
	}
	
	@Test( "test mixed dependencies checking" )
	public function testMixedDependenciesChecking() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/static/mixedDependencies.flow" );
		
		var s = this._getCoreFactory().locate( "s" );
		var mapping1 = this._getCoreFactory().locate( "mapping1" );
		var mapping2 = this._getCoreFactory().locate( "mapping2" );
		var mappings = this._getCoreFactory().locate( "mappings" );
		
		Assert.equals( "String", mapping1.fromType );
		Assert.equals( "test", mapping1.toValue );
		Assert.equals( s, mapping1.toValue );
		
		Assert.equals( "hex.mock.Interface", mapping2.fromType );
		Assert.isInstanceOf( mapping2.toValue, hex.mock.Clazz );
		Assert.equals( "anotherID", mapping2.withName );
		
		Assert.equals( mapping2, mappings[0] );
		
		var mapping = mappings[ 1 ];
		Assert.equals( "hex.mock.Interface", mapping.fromType );
		Assert.equals( hex.mock.Clazz, mapping.toClass );
		Assert.equals( "id", mapping.withName );
		
		var injector : IDependencyInjector = cast this._getCoreFactory().locate( "owner" ).getInjector();
		Assert.equals( "test", injector.getInstanceWithClassName( "String" ) );
		Assert.isInstanceOf( injector.getInstanceWithClassName( "hex.mock.Interface", "anotherID" ), hex.mock.Clazz );
		Assert.equals( injector.getInstanceWithClassName( "hex.mock.Interface", "anotherID" ), injector.getInstanceWithClassName( "hex.mock.Interface", "anotherID" ) );
		
		var instance = injector.getInstanceWithClassName( "hex.mock.Interface", "id" );
		Assert.isInstanceOf( instance, hex.mock.Clazz );
		Assert.equals( instance, injector.getInstanceWithClassName( "hex.mock.Interface", "id" ) );
	}
	
	@Test( "test property recursivity" )
	public function testPropertyRecursivity() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/propertyRecursivity.flow" );

		var o1 = this._getCoreFactory().locate( "o1" );
		var o2 = this._getCoreFactory().locate( "o2" );
		var r = this._getCoreFactory().locate( "r" );
		
		Assert.isInstanceOf( o1.p, hex.mock.Clazz );
		
		Assert.isInstanceOf( o2.p, hex.mock.MockContextHolder );
		Assert.isInstanceOf( o2.p.context, hex.mock.MockApplicationContext );
		
		Assert.equals( 10, r.width );
		Assert.equals( 20, r.height );
	}
	
	@Test( "test add custom parser" )
	public function testAddCustomParser() : Void
	{
		MockCustomStaticFlowParser.prepareCompiler();
		this._applicationAssembler = FlowCompiler.compile( "context/flow/static/addParser.flow" );
		
		Assert.equals( 'hello world !', this._getCoreFactory().locate( "s" ) );
		Assert.equals( 11, this._getCoreFactory().locate( "i" ) );
		Assert.equals( 11, this._getCoreFactory().locate( "p" ).x );
		Assert.equals( 13, this._getCoreFactory().locate( "p" ).y );
	}
	
	@Test( "test alias primitive" )
	public function testAliasPrimitive() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/aliasPrimitive.flow" );
		
		Assert.equals( 5, this._getCoreFactory().locate( "value" ) );
		Assert.equals( this._getCoreFactory().locate( "value" ), this._getCoreFactory().locate( "x" ) );
		
		var i : Int = this._getCoreFactory().locate( "x" );
		Assert.equals( 5, i );
	}
	
	@Test( "test alias instance" )
	public function testAliasInstance() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/aliasInstance.flow" );

		var position = this._getCoreFactory().locate( "reference" );
		Assert.equals( 1, this._getCoreFactory().locate( "position" ).x );
		Assert.equals( 2, this._getCoreFactory().locate( "position" ).y );
	}
	
	@Test( "test Array concat with util" )
	public function testArrayConcatWithUtil() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/arrayConcat.flow" );
		Assert.deepEquals( [1,2,3,4,5,6], this._getCoreFactory().locate( "result" ) );
	}
	
	@Test( "test abstract typed field with map-type" )
	public function testAbstractTypedFieldWithMapType() : Void
	{
		//We just check here that @type metadata doesn't prevent flow compilation
		this._applicationAssembler = FlowCompiler.compile( "context/flow/static/abstractTypeField.flow" );

		Assert.isInstanceOf( this._getCoreFactory().locate( "test" ), MockClass );

		var map = this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstanceWithClassName( "hex.mock.IMockInterface", "test" );
		Assert.isInstanceOf( map, MockClass );
		Assert.equals( this._getCoreFactory().locate( "test" ), map );
	}
}