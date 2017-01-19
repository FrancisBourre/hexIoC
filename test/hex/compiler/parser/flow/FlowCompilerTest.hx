package hex.compiler.parser.flow;

import hex.collection.HashMap;
import hex.compiler.parser.flow.FlowCompiler;
import hex.control.command.BasicCommand;
import hex.core.IApplicationAssembler;
import hex.core.ICoreFactory;
import hex.domain.ApplicationDomainDispatcher;
import hex.event.EventProxy;
import hex.ioc.core.IContextFactory;
import hex.ioc.parser.xml.ApplicationXMLParser;
import hex.ioc.parser.xml.mock.ClassWithConstantConstantArgument;
import hex.ioc.parser.xml.mock.MockCaller;
import hex.ioc.parser.xml.mock.MockChatModule;
import hex.ioc.parser.xml.mock.MockClassWithInjectedProperty;
import hex.ioc.parser.xml.mock.MockFruitVO;
import hex.ioc.parser.xml.mock.MockReceiverModule;
import hex.ioc.parser.xml.mock.MockRectangle;
import hex.ioc.parser.xml.mock.MockServiceProvider;
import hex.ioc.parser.xml.mock.MockStubStatefulService;
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
	var _contextFactory 			: IContextFactory;
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
		return this._applicationAssembler.getApplicationContext( "applicationContext" ).getCoreFactory();
	}
	
	@Test( "test building String with assembler" )
	public function testBuildingStringWithAssembler() : Void
	{
		var assembler = new ApplicationAssembler();
		assembler.getApplicationContext( "applicationContext" ).getCoreFactory().register( "s2", "bonjour" );
		
		this._applicationAssembler = FlowCompiler.compileWithAssembler( assembler, "context/flow/testBuildingString.flow" );

		Assert.equals( "hello", this._getCoreFactory().locate( "s" ) );
		Assert.equals( "bonjour", this._getCoreFactory().locate( "s2" ) );
		Assert.equals( assembler, this._applicationAssembler );
	}
	
	@Test( "test building String instances with the same assembler at compile time and runtime" )
	public function testBuildingStringsMixingCompileTimeAndRuntime() : Void
	{
		var assembler = new ApplicationAssembler();
		ApplicationXMLParser.parseString( assembler, '<root name="applicationContext"><test id="s2" value="hola"/></root>' );
		this._applicationAssembler = FlowCompiler.compileWithAssembler( assembler, "context/flow/testBuildingString.flow" );

		Assert.equals( "hello", this._getCoreFactory().locate( "s" ) );
		Assert.equals( "hola", this._getCoreFactory().locate( "s2" ) );
		Assert.equals( assembler, this._applicationAssembler );
	}
	
	@Ignore( "test building String" )
	public function testBuildingString() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/testBuildingString.flow" );
		var s : String = this._getCoreFactory().locate( "s" );
		Assert.equals( "hello", s );
	}
	
	@Test( "test building String with assembler property" )
	public function testBuildingStringWithAssemblerProperty() : Void
	{
		this._applicationAssembler = new ApplicationAssembler();
		FlowCompiler.compileWithAssembler( this._applicationAssembler, "context/flow/testBuildingString.flow" );
		var s : String = this._getCoreFactory().locate( "s" );
		Assert.equals( "hello", s );
	}
	
	@Ignore( "test building String with assembler static property" )
	public function testBuildingStringWithAssemblerStaticProperty() : Void
	{
		FlowCompilerTest.applicationAssembler = new ApplicationAssembler();
		FlowCompiler.compileWithAssembler( FlowCompilerTest.applicationAssembler, "context/flow/testBuildingString.flow" );
		var s : String = this._getCoreFactory().locate( "s" );
		Assert.equals( "hello", s );
	}
	
	@Ignore( "test read twice the same context" )
	public function testReadTwiceTheSameContext() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		this._applicationAssembler = new ApplicationAssembler();
		
		FlowCompiler.compileWithAssembler( this._applicationAssembler, "context/flow/simpleInstanceWithoutArguments.flow" );
		FlowCompiler.compileWithAssembler( this._applicationAssembler, "context/flow/simpleInstanceWithoutArguments.flow" );
		
		var coreFactory = applicationAssembler.getApplicationContext( "applicationContext" ).getCoreFactory();

		var command1 = coreFactory.locate( "command" );
		Assert.isInstanceOf( command1, BasicCommand );
		
		var command2 = this._getCoreFactory().locate( "command" );
		Assert.isInstanceOf( command2, BasicCommand );
		
		Assert.notEquals( command1, command2 );
	}
	
	@Test( "test building Int" )
	public function testBuildingInt() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/testBuildingInt.flow" );
		var i : Int = this._getCoreFactory().locate( "i" );
		Assert.equals( -3, i );
	}
	
	@Test( "test building Hex" )
	public function testBuildingHex() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/testBuildingHex.flow" );
		Assert.equals( 0xFFFFFF, this._getCoreFactory().locate( "i" ) );
	}
	
	@Test( "test building Bool" )
	public function testBuildingBool() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/testBuildingBool.flow" );
		var b : Bool = this._getCoreFactory().locate( "b" );
		Assert.isTrue( b );
	}
	
	@Test( "test building UInt" )
	public function testBuildingUInt() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/testBuildingUInt.flow" );
		var i : UInt = this._getCoreFactory().locate( "i" );
		Assert.equals( 3, i );
	}
	
	@Test( "test building null" )
	public function testBuildingNull() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/testBuildingNull.flow" );
		var result : Dynamic = this._getCoreFactory().locate( "value" );
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

		var command : BasicCommand = this._getCoreFactory().locate( "command" );
		Assert.isInstanceOf( command, BasicCommand );
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
	
	@Test( "test building single instance with object references" )
	public function testBuildingSingleInstanceWithObjectReferences() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/singleInstanceWithObjectReferences.flow" );
		
		var chat : MockChatModule = this._getCoreFactory().locate( "chat" );
		Assert.isInstanceOf( chat, MockChatModule );
		
		var receiver : MockReceiverModule = this._getCoreFactory().locate( "receiver" );
		Assert.isInstanceOf( receiver, MockReceiverModule );
		
		var proxyChat : EventProxy = this._getCoreFactory().locate( "proxyChat" );
		Assert.isInstanceOf( proxyChat, EventProxy );
		
		var proxyReceiver : EventProxy = this._getCoreFactory().locate( "proxyReceiver" );
		Assert.isInstanceOf( proxyReceiver, EventProxy );

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
	
	@Test( "test 'injector-creation' attribute" )
	public function testInjectorCreationAttribute() : Void
	{
		var assembler = new ApplicationAssembler();
		var injector = assembler.getApplicationContext( "applicationContext" ).getCoreFactory().getInjector();
		injector.mapToValue( String, 'hola mundo' );
		
		this._applicationAssembler = FlowCompiler.compileWithAssembler( assembler, "context/flow/injectorCreationAttribute.flow" );

		var instance : MockClassWithInjectedProperty = this._getCoreFactory().locate( "instance" );
		Assert.isInstanceOf( instance, MockClassWithInjectedProperty, "" );
		Assert.equals( "hola mundo", instance.property, "" );
		Assert.isTrue( instance.postConstructWasCalled, "" );
	}
	
	@Test( "test 'inject-into' attribute" )
	public function testInjectIntoAttribute() : Void
	{
		var assembler = new ApplicationAssembler();
		var injector = assembler.getApplicationContext( "applicationContext" ).getCoreFactory().getInjector();
		injector.mapToValue( String, 'hola mundo' );

		this._applicationAssembler = FlowCompiler.compileWithAssembler( assembler, "context/flow/injectIntoAttribute.flow" );

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

		var fruits : HashMap<Dynamic, MockFruitVO> = this._getCoreFactory().locate( "fruits" );
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
	
	/*
	@Ignore( "test building HashMap with map-type" )
	public function testBuildingHashMapWithMapType() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/hashmapWithMapType.xml" );

		var fruits : HashMap<Dynamic, MockFruitVO> = this._getCoreFactory().locate( "fruits" );
		Assert.isNotNull( fruits, "" );

		var orange 	: MockFruitVO = fruits.get( '0' );
		var apple 	: MockFruitVO = fruits.get( '1' );

		Assert.equals( "orange", orange.toString(), "" );
		Assert.equals( "apple", apple.toString(), "" );
		
		var map = this._getCoreFactory().getInjector().getInstanceWithClassName( "hex.collection.HashMap<String,hex.ioc.parser.xml.mock.MockFruitVO>", "fruits" );
		Assert.equals( fruits, map );
	}
	
	@Ignore( "test map-type attribute with Array" )
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
	
	@Ignore( "test map-type attribute with instance" )
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
	
	@Ignore( "test building two modules listening each other" )
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
	
	@Ignore( "test building two modules listening each other with adapter" )
	public function testBuildingTwoModulesListeningEachOtherWithAdapter() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/twoModulesListeningEachOtherWithAdapter.xml" );

		var chat : MockChatModule = this._getCoreFactory().locate( "chat" );
		Assert.isNotNull( chat, "" );
		Assert.isNull( chat.translatedMessage, "" );

		var translation : MockTranslationModule = this._getCoreFactory().locate( "translation" );
		Assert.isNotNull( translation, "" );

		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "Hello", chat.translatedMessage, "" );
		Assert.isInstanceOf( chat.date, Date, "" );
	}
	
	@Ignore( "test building two modules listening each other with adapter and injection" )
	public function testBuildingTwoModulesListeningEachOtherWithAdapterAndInjection() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/twoModulesListeningEachOtherWithAdapterAndInjection.xml" );

		var chat : MockChatModule = this._getCoreFactory().locate( "chat" );
		Assert.isNotNull( chat, "" );

		var receiver : MockReceiverModule = this._getCoreFactory().locate( "receiver" );
		Assert.isNotNull( receiver, "" );

		var parser : MockMessageParserModule = this._getCoreFactory().locate( "parser" );
		Assert.isNotNull( parser, "" );

		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "BONJOUR", receiver.message, "" );
	}
	
	@Ignore( "test domain dispatch after module initialisation" )
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
	
	/*
	@Ignore( "test building mapping configuration" )
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
	}
	
	@Ignore( "test building serviceLocator" )
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
	
	@Ignore( "test building serviceLocator with map names" )
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
	*/
	
	@Test( "test static-ref" )
	public function testStaticRef() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/staticRef.flow" );

		var note : String = this._getCoreFactory().locate( "constant" );
		Assert.isNotNull( note );
		Assert.equals( note, MockStubStatefulService.INT_VO_UPDATE );
	}
	
	@Test( "test static-ref property" )
	public function testStaticProperty() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/staticRefProperty.flow" );

		var object : Dynamic = this._getCoreFactory().locate( "object" );
		Assert.isNotNull( object );
		Assert.equals( MockStubStatefulService.INT_VO_UPDATE, object.property );
		
		var object2 : Dynamic = this._getCoreFactory().locate( "object2" );
		Assert.isNotNull( object2 );
		Assert.equals( MockStubStatefulService, object2.property );
	}
	
	@Test( "test static-ref argument" )
	public function testStaticArgument() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/staticRefArgument.flow" );

		var instance : ClassWithConstantConstantArgument = this._getCoreFactory().locate( "instance" );
		Assert.isNotNull( instance, "" );
		Assert.equals( instance.constant, MockStubStatefulService.INT_VO_UPDATE, "" );
	}
	
	/*@Test( "test static-ref argument on method-call" )
	public function testStaticArgumentOnMethodCall() : Void
	{
		this._applicationAssembler = XmlCompiler.readXmlFile( "context/staticRefArgumentOnMethodCall.xml" );

		var instance : MockMethodCaller = this._getCoreFactory().locate( "instance" );
		Assert.isNotNull( instance, "" );
		Assert.equals( MockMethodCaller.staticVar, instance.argument, "" );
	}*/
	
	/*@Ignore( "test map-type attribute" )
	public function testMapTypeAttribute() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/mapTypeAttribute.flow" );

		var myModule : MockMappedModule = this._getCoreFactory().locate( "myModule" );
		Assert.isNotNull( myModule );
		Assert.isInstanceOf( myModule, MockMappedModule );
		Assert.equals( myModule, this._applicationAssembler.getApplicationContext( "applicationContext" ).getInjector().getInstance( IMockMappedModule, "myModule" ), "" );
	}
	
	@Ignore( "test multi map-type attributes" )
	public function testMultiMapTypeAttributes() : Void
	{
		this._applicationAssembler = FlowCompiler.compile( "context/flow/multiMapTypeAttributes.flow" );

		var myModule : MockMappedModule = this._getCoreFactory().locate( "myModule" );
		Assert.isNotNull( myModule );
		Assert.isInstanceOf( myModule, MockMappedModule );
		Assert.isInstanceOf( myModule, IAnotherMockMappedModule );
		
		Assert.equals( myModule, this._applicationAssembler.getApplicationContext( "applicationContext" ).getInjector().getInstance( IMockMappedModule, "myModule" ), "" );
		Assert.equals( myModule, this._applicationAssembler.getApplicationContext( "applicationContext" ).getInjector().getInstance( IAnotherMockMappedModule, "myModule" ), "" );
	}
	
	@Ignore( "test static-ref with factory" )
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
		this._applicationAssembler = FlowCompiler.compile( "context/flow/ifAttribute.flow" );
		Assert.equals( "hello message", this._getCoreFactory().locate( "message" ), "message value should equal 'hello production'" );
	}
}