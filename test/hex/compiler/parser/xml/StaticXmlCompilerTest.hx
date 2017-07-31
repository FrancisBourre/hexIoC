package hex.compiler.parser.xml;

import haxe.Timer;
import hex.compiler.parser.xml.StaticXmlCompiler;
import hex.core.IApplicationAssembler;
import hex.di.Injector;
import hex.di.mapping.MappingConfiguration;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.error.Exception;
import hex.error.NoSuchElementException;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.parser.xml.mock.IMockStubStatefulService;
import hex.ioc.parser.xml.mock.MockAsyncCommandWithAnnotation;
import hex.ioc.parser.xml.mock.MockBooleanVO;
import hex.ioc.parser.xml.mock.MockChatModule;
import hex.ioc.parser.xml.mock.MockCommandWithAnnotation;
import hex.ioc.parser.xml.mock.MockDocument;
import hex.ioc.parser.xml.mock.MockIntVO;
import hex.ioc.parser.xml.mock.MockMacroWithAnnotation;
import hex.ioc.parser.xml.mock.MockReceiverModule;
import hex.metadata.AnnotationProvider;
import hex.metadata.IAnnotationProvider;
import hex.mock.AnotherMockClass;
import hex.mock.IAnotherMockInterface;
import hex.mock.IMockInjectee;
import hex.mock.IMockInterface;
import hex.mock.MockCaller;
import hex.mock.MockChat;
import hex.mock.MockClass;
import hex.mock.MockClassWithGeneric;
import hex.mock.MockClassWithInjectedProperty;
import hex.mock.MockClassWithoutArgument;
import hex.mock.MockInjectee;
import hex.mock.MockMethodCaller;
import hex.mock.MockObjectWithRegtangleProperty;
import hex.mock.MockProxy;
import hex.mock.MockReceiver;
import hex.mock.MockRectangle;
import hex.mock.MockServiceProvider;
import hex.mock.MockWeatherModel;
import hex.runtime.ApplicationAssembler;
import hex.structures.Size;
import hex.unittest.assertion.Assert;
import hex.unittest.runner.MethodRunner;

/**
 * ...
 * @author Francis Bourre
 */
class StaticXmlCompilerTest
{
	var _applicationAssembler : IApplicationAssembler;
	static var applicationAssembler : IApplicationAssembler;

	@Before
	public function setUp() : Void
	{
		this._applicationAssembler = new ApplicationAssembler();
	}
	
	@After
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.getInstance().clear();
		this._applicationAssembler.release();
	}

	@Test( "test building String" )
	public function testBuildingString() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/primitives/string.xml", "StaticXmlCompiler_testBuildingString" );
		
		var locator = code.locator;
		Assert.isNull( locator.s );
		
		code.execute();
		
		Assert.equals( "hello", locator.s );
	}
	
	@Test( "test context reference" )
	public function testContextReference() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/contextReference.xml", "StaticXmlCompiler_testContextReference" );
		code.execute();
		Assert.equals( code.applicationContext, code.locator.contextHolder.context );
	}
	
	@Test( "test building String without context name" )
	public function testBuildingStringWithoutContextName() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/contextWithoutName.xml", "StaticXmlCompiler_testBuildingStringWithoutContextName" );
		code.execute();
		Assert.equals( "hello", code.locator.s );
	}
	
	@Test( "test building String with assembler static property" )
	public function testBuildingStringWithAssemblerStaticProperty() : Void
	{
		StaticXmlCompilerTest.applicationAssembler = new ApplicationAssembler();
		var code = StaticXmlCompiler.compile( StaticXmlCompilerTest.applicationAssembler, "context/xml/primitives/string.xml", "StaticXmlCompiler_testBuildingStringWithAssemblerStaticProperty" );
		code.execute();
		
		var s : String = StaticXmlCompilerTest.applicationAssembler.getApplicationContext( "StaticXmlCompiler_testBuildingStringWithAssemblerStaticProperty", ApplicationContext ).getCoreFactory().locate( "s" );
		Assert.equals( "hello", s );
	}
	
	@Test( "test overriding context name" )
	public function testOverridingContextName() : Void
	{
		var code1 = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/simpleInstanceWithoutArguments.xml", "StaticXmlCompiler_testOverridingContextName1" );
		var code2 = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/simpleInstanceWithoutArguments.xml", "StaticXmlCompiler_testOverridingContextName2" );
		
		code1.execute();
		code2.execute();

		Assert.isInstanceOf( code1.locator.instance, MockClassWithoutArgument );
		Assert.isInstanceOf( code2.locator.instance, MockClassWithoutArgument );
		Assert.notEquals( code1.locator.instance, code2.locator.instance );
	}
	
	//Primitives
	@Test( "test building Int" )
	public function testBuildingInt() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/primitives/int.xml", "StaticXmlCompiler_testBuildingInt" );
		code.execute();
		Assert.equals( -3, code.locator.i );
	}
	
	@Test( "test building Hex" )
	public function testBuildingHex() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/primitives/hex.xml", "StaticXmlCompiler_testBuildingHex" );
		code.execute();
		Assert.equals( 0xFFFFFF, code.locator.i );
	}
	
	@Test( "test building Bool" )
	public function testBuildingBool() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/primitives/bool.xml", "StaticXmlCompiler_testBuildingBool" );
		code.execute();
		Assert.isTrue( code.locator.b );
	}
	
	@Test( "test building UInt" )
	public function testBuildingUInt() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/primitives/uint.xml", "StaticXmlCompiler_testBuildingUInt" );
		code.execute();
		Assert.equals( 3, code.locator.i );
	}
	
	@Test( "test building null" )
	public function testBuildingNull() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/primitives/null.xml", "StaticXmlCompiler_testBuildingNull" );
		code.execute();
		Assert.isNull( code.locator.value );
	}
	
	@Test( "test building anonymous object" )
	public function testBuildingAnonymousObject() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/anonymousObject.xml", "StaticXmlCompiler_testBuildingAnonymousObject" );
		code.execute();
		
		//TODO make structure with typed properties
		var obj = code.locator.obj;

		Assert.equals( "Francis", obj.name );
		Assert.equals( 44, obj.age );
		Assert.equals( 1.75, obj.height );
		Assert.isTrue( obj.isWorking );
		Assert.isFalse( obj.isSleeping );
	}
	
	@Test( "test building simple instance without arguments" )
	public function testBuildingSimpleInstanceWithoutArguments() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/simpleInstanceWithoutArguments.xml", "StaticXmlCompiler_testBuildingSimpleInstanceWithoutArguments" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClassWithoutArgument );
	}
	
	@Test( "test building simple instance with arguments" )
	public function testBuildingSimpleInstanceWithArguments() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/simpleInstanceWithArguments.xml", "StaticXmlCompiler_testBuildingSimpleInstanceWithArguments" );
		
		var locator = code.locator;
		Assert.isNull( locator.size );
		
		code.execute();

		Assert.isInstanceOf( locator.size, Size );
		Assert.equals( 10, locator.size.width );
		Assert.equals( 20, locator.size.height );
	}
	
	@Test( "test building multiple instances with arguments" )
	public function testBuildingMultipleInstancesWithArguments() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/multipleInstancesWithArguments.xml", "StaticXmlCompiler_testBuildingMultipleInstancesWithArguments" );
		var locator = code.locator;
		code.execute();
		
		var rect = locator.rect;
		Assert.isInstanceOf( rect, MockRectangle );
		Assert.equals( 10, rect.x );
		Assert.equals( 20, rect.y );
		Assert.equals( 30, rect.width );
		Assert.equals( 40, rect.height );
		
		var size = locator.size;
		Assert.isInstanceOf( size, Size );
		Assert.equals( 15, size.width );
		Assert.equals( 25, size.height );

		var position = locator.position;
		Assert.equals( 35, position.x );
		Assert.equals( 45, position.y );
	}
	
	@Test( "test building single instance with primitives references" )
	public function testBuildingSingleInstanceWithPrimitivesReferences() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		var code = StaticXmlCompiler.compile( applicationAssembler, "context/xml/singleInstanceWithPrimReferences.xml", "StaticXmlCompiler_testBuildingSingleInstanceWithPrimitivesReferences" );
		var locator = code.locator;
		code.execute();
		
		var x = locator.x;
		Assert.equals( 1, x );
		
		var y = locator.y;
		Assert.equals( 2, y );

		var position = locator.position;
		Assert.equals( 1, position.x );
		Assert.equals( 2, position.y );
	}
	
	@Test( "test building single instance with method references" )
	public function testBuildingSingleInstanceWithMethodReferences() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		var code = StaticXmlCompiler.compile( applicationAssembler, "context/xml/singleInstanceWithMethodReferences.xml", "StaticXmlCompiler_testBuildingSingleInstanceWithMethodReferences" );
		var locator = code.locator;
		code.execute();
		
		var chat = locator.chat;
		Assert.isInstanceOf( chat, MockChat );
		
		var receiver = locator.receiver;
		Assert.isInstanceOf( receiver, MockReceiver );
		
		var proxyChat = locator.proxyChat;
		Assert.isInstanceOf( proxyChat, MockProxy );
		
		var proxyReceiver = locator.proxyReceiver;
		Assert.isInstanceOf( proxyReceiver, MockProxy );

		Assert.equals( chat, proxyChat.scope );
		Assert.equals( chat.onTranslation, proxyChat.callback );
		
		Assert.equals( receiver, proxyReceiver.scope );
		Assert.equals( receiver.onMessage, proxyReceiver.callback );
	}
	
	@Test( "test assign instance property with references" )
	public function testAssignInstancePropertyWithReference() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		var code = StaticXmlCompiler.compile( applicationAssembler, "context/xml/instancePropertyWithReference.xml", "StaticXmlCompiler_testAssignInstancePropertyWithReference" );
		var locator = code.locator;
		code.execute();
		
		var width = locator.width;
		Assert.equals( 10, width );
		
		var height = locator.height;
		Assert.equals( 20, height );
		
		var size = locator.size;
		Assert.equals( width, size.x );
		Assert.equals( height, size.y );
		
		var rect = locator.rect;
		Assert.equals( width, rect.size.x );
		Assert.equals( height, rect.size.y );
	}
	
	@Test( "test building multiple instances with references" )
	public function testBuildingMultipleInstancesWithReferences() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		var code = StaticXmlCompiler.compile( applicationAssembler, "context/xml/multipleInstancesWithReferences.xml", "StaticXmlCompiler_testBuildingMultipleInstancesWithReferences" );
		var code2 = StaticXmlCompiler.extend( applicationAssembler, code, "context/xml/simpleInstanceWithoutArguments.xml" );
		var code3 = StaticXmlCompiler.extend( applicationAssembler, code, "context/xml/multipleInstancesWithReferencesReferenced.xml" );
		
		var locator = code.locator;
		var locator2 = code2.locator;
		var locator3 = code3.locator;
		
		//1st pass
		code.execute();

		var rectSize = locator.rectSize;

		Assert.equals( 30, rectSize.x );
		Assert.equals( 40, rectSize.y );

		var rectPosition = locator.rectPosition;
		Assert.equals( 10, rectPosition.x );
		Assert.equals( 20, rectPosition.y );

		var rect = ( locator.rect : MockRectangle);
		Assert.isInstanceOf( rect, MockRectangle );
		Assert.equals( 10, rect.x );
		Assert.equals( 20, rect.y );
		Assert.equals( 30, rect.size.x );
		Assert.equals( 40, rect.size.y );
		
		//2nd pass
		code2.execute();
		
		Assert.isInstanceOf( locator2.instance, MockClassWithoutArgument );
		Assert.equals( locator.rectSize, locator2.rectSize );
		
		//3rd pass
		code3.execute();
		
		var anotherRect = ( locator3.anotherRect : MockRectangle);
		Assert.isInstanceOf( anotherRect, MockRectangle );
		Assert.equals( 10, anotherRect.x );
		Assert.equals( 20, anotherRect.y );
		Assert.equals( 30, anotherRect.size.x );
		Assert.equals( 40, anotherRect.size.y );
		
		//Check data synchronisation/integrity
		locator.rectSize = null;
		Assert.isNull( locator2.rectSize );
		Assert.isNull( locator3.rectSize );
		
		locator2.rectPosition = null;
		Assert.isNull( locator.rectPosition );
		
		Assert.equals( locator, locator2 );
		Assert.equals( locator, locator3 );
		Assert.equals( locator2, locator3 );
	}
	
	@Test( "test applicationContext building" )
	public function testApplicationContextBuilding() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		var code1 = StaticXmlCompiler.compile( applicationAssembler, "context/xml/ioc/IoCApplicationContextBuildingTest.xml", "StaticXmlCompiler_testApplicationContextBuilding1" );
		
		//application assembler reference stored
		Assert.equals( applicationAssembler, code1.applicationAssembler );
		
		//Custom application context is available before code execution
		Assert.equals( code1.applicationContext, code1.locator.StaticXmlCompiler_testApplicationContextBuilding1 );
		
		//auto-completion is woking on custom applicationContext's class
		Assert.equals( 'test', code1.applicationContext.getTest() );
		Assert.equals( 'test', code1.locator.StaticXmlCompiler_testApplicationContextBuilding1.getTest() );
		
		//
		code1.execute();

		//
		Assert.isInstanceOf( code1.locator.StaticXmlCompiler_testApplicationContextBuilding1, hex.mock.MockIoCApplicationContext );
		Assert.equals( "Hola Mundo", code1.locator.test );
		
		//
		var code2 = StaticXmlCompiler.compile( applicationAssembler, "context/xml/ioc/IoCApplicationContextBuildingTest.xml", "StaticXmlCompiler_testApplicationContextBuilding2" );
		Assert.isInstanceOf( code2.locator.StaticXmlCompiler_testApplicationContextBuilding2, hex.mock.MockIoCApplicationContext );
		Assert.equals( "Hola Mundo", code1.locator.test );
		
		//Parallel duplicated code generations and contexts are not the same
		Assert.notEquals( code1, code2 );
		Assert.notEquals( code1.applicationContext, code2.applicationContext );
		Assert.notEquals( code1.locator.StaticXmlCompiler_testApplicationContextBuilding1, code2.locator.StaticXmlCompiler_testApplicationContextBuilding2 );
		
		//Extended code generation uses the same application context
		var code3 = StaticXmlCompiler.extend( applicationAssembler, code2, "context/xml/simpleInstanceWithoutArguments.xml", "StaticXmlCompiler_testApplicationContextBuilding2" );
		Assert.notEquals( code2, code3 );
		Assert.equals( code2.applicationContext, code3.applicationContext );
		Assert.equals( code2.locator.StaticXmlCompiler_testApplicationContextBuilding2, code3.locator.StaticXmlCompiler_testApplicationContextBuilding2 );
	
		//Compare assemblers
		Assert.equals( code1.applicationAssembler, code2.applicationAssembler );
		Assert.equals( code1.applicationAssembler, code3.applicationAssembler );
		Assert.equals( code2.applicationAssembler, code3.applicationAssembler );
	}
	
	@Test( "test simple method call" )
	public function testSimpleMethodCall() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/simpleMethodCall.xml", "StaticXmlCompiler_testSimpleMethodCall" );
		code.execute();

		Assert.isInstanceOf( code.locator.caller, MockCaller );
		Assert.deepEquals( [ "hello", "world" ], MockCaller.passedArguments );
	}
	
	@Test( "test simple method call from another node" )
	public function testSimpleMethodCallFromAnotherNode() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/simpleMethodCallFromAnotherNode.xml", "StaticXmlCompiler_testSimpleMethodCallFromAnotherNode" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.caller, MockCaller );
		Assert.deepEquals( [ "hello", "world" ], MockCaller.passedArguments );
	}
	
	@Test( "test method call with type params" )
	public function testCallWithTypeParams() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/methodCallWithTypeParams.xml", "StaticXmlCompiler_testCallWithTypeParams" );
		code.execute();

		Assert.isInstanceOf( code.locator.caller, MockCaller );
		Assert.equals( 3, MockCaller.passedArray.length );
	}
	
	@Test( "test building multiple instances with method calls" )
	public function testBuildingMultipleInstancesWithMethodCall() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/multipleInstancesWithMethodCall.xml", "StaticXmlCompiler_testBuildingMultipleInstancesWithMethodCall" );
		code.execute();

		Assert.equals( 30, code.locator.rectSize.x );
		Assert.equals( 40, code.locator.rectSize.y );

		Assert.equals( 10, code.locator.rectPosition.x );
		Assert.equals( 20, code.locator.rectPosition.y );

		Assert.isInstanceOf( code.locator.rect, MockRectangle );
		Assert.equals( 10, code.locator.rect.x );
		Assert.equals( 20, code.locator.rect.y );
		Assert.equals( 30, code.locator.rect.width );
		Assert.equals( 40, code.locator.rect.height );

		Assert.isInstanceOf( code.locator.anotherRect, MockRectangle );
		Assert.equals( 0, code.locator.anotherRect.x );
		Assert.equals( 0, code.locator.anotherRect.y );
		Assert.equals( 0, code.locator.anotherRect.width );
		Assert.equals( 0, code.locator.anotherRect.height );
	}
	
	@Test( "test building instance with static method" )
	public function testBuildingInstanceWithStaticMethod() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/instanceWithStaticMethod.xml", "StaticXmlCompiler_testBuildingInstanceWithStaticMethod" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.service, MockServiceProvider );
		Assert.equals( "http://localhost/amfphp/gateway.php", code.locator.service.getGateway() );
		Assert.equals( "http://localhost/amfphp/gateway.php", MockServiceProvider.getInstance().getGateway() );
	}
	
	@Test( "test building instance with static method and arguments" )
	public function testBuildingInstanceWithStaticMethodAndArguments() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/instanceWithStaticMethodAndArguments.xml", "StaticXmlCompiler_testBuildingInstanceWithStaticMethodAndArguments" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.rect, MockRectangle );
		Assert.equals( 10, code.locator.rect.x );
		Assert.equals( 20, code.locator.rect.y );
		Assert.equals( 30, code.locator.rect.width );
		Assert.equals( 40, code.locator.rect.height );
	}
	
	@Test( "test building instance with static method and factory method" )
	public function testBuildingInstanceWithStaticMethodAndFactoryMethod() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/instanceWithStaticMethodAndFactoryMethod.xml", "StaticXmlCompiler_testBuildingInstanceWithStaticMethodAndFactoryMethod" );
		code.execute();
		
		Assert.equals( 10, code.locator.point.x );
		Assert.equals( 20, code.locator.point.y );
	}
	
	@Test( "test 'inject-into' attribute" )
	public function testInjectIntoAttribute() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/injectIntoAttribute.xml", "StaticXmlCompiler_testInjectIntoAttribute" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClassWithInjectedProperty );
		Assert.equals( "hola mundo", code.locator.instance.property );
		Assert.isTrue( code.locator.instance.postConstructWasCalled );
	}
	
	@Test( "test building XML without parser class" )
	public function testBuildingXMLWithoutParserClass() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/xmlWithoutParserClass.xml", "StaticXmlCompiler_testBuildingXMLWithoutParserClass" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.fruits, Xml );
	}
	
	@Test( "test building XML with parser class" )
	public function testBuildingXMLWithParserClass() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/xmlWithParserClass.xml", "StaticXmlCompiler_testBuildingXMLWithParserClass" );
		code.execute();

		Assert.equals( 3, code.locator.fruits.length );

		var orange = code.locator.fruits[0];
		var apple = code.locator.fruits[1];
		var banana = code.locator.fruits[2];

		Assert.equals( "orange", orange.toString() );
		Assert.equals( "apple", apple.toString() );
		Assert.equals( "banana", banana.toString() );
	}
	
	@Test( "test building Arrays" )
	public function testBuildingArrays() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/arrayFilledWithReferences.xml", "StaticXmlCompiler_testBuildingArrays" );
		code.execute();
		
		Assert.equals( 2, code.locator.text.length );
		Assert.equals( "hello", code.locator.text[ 0 ] );
		Assert.equals( "world", code.locator.text[ 1 ] );

		Assert.equals( 0, code.locator.empty.length );

		Assert.equals( 3, code.locator.fruits.length, "" );

		var orange 	= code.locator.fruits[0];
		var apple 	= code.locator.fruits[1];
		var banana 	= code.locator.fruits[2];

		Assert.equals( "orange", orange.toString()  );
		Assert.equals( "apple", apple.toString() );
		Assert.equals( "banana", banana.toString() );
	}
	
	@Test( "test building Map filled with references" )
	public function testBuildingMapFilledWithReferences() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/hashmapFilledWithReferences.xml", "StaticXmlCompiler_testBuildingMapFilledWithReferences" );
		code.execute();

		var fruits = code.locator.fruits;
		Assert.isNotNull( fruits );

		var stubKey = code.locator.stubKey;
		Assert.isNotNull( stubKey );

		var orange 	= code.locator.fruits.get( '0' );
		var apple 	= code.locator.fruits.get( 1 );
		var banana 	= code.locator.fruits.get( stubKey );

		Assert.equals( "orange", orange.toString() );
		Assert.equals( "apple", apple.toString() );
		Assert.equals( "banana", banana.toString() );
	}
	
	@Test( "test building HashMap with map-type" )
	public function testBuildingHashMapWithMapType() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/hashmapWithMapType.xml", "StaticXmlCompiler_testBuildingHashMapWithMapType" );
		code.execute();

		Assert.isNotNull( code.locator.fruits );

		var orange 	= code.locator.fruits.get( '0' );
		var apple 	= code.locator.fruits.get( '1' );

		Assert.equals( "orange", orange.toString() );
		Assert.equals( "apple", apple.toString() );
		
		var map = code.applicationContext.getInjector().getInstanceWithClassName( "hex.collection.HashMap<String,hex.mock.MockFruitVO>", "fruits" );
		Assert.equals( code.locator.fruits, map );
	}
	
	@Test( "test map-type attribute with Array" )
	public function testMapTypeWithArray() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/mapTypeWithArray.xml", "StaticXmlCompiler_testMapTypeWithArray" );
		code.execute();
		
		var intCollection = code.applicationContext.getInjector().getInstanceWithClassName( "Array<Int>", "intCollection" );
		var uintCollection = code.applicationContext.getInjector().getInstanceWithClassName( "Array<UInt>", "intCollection" );
		var stringCollection = code.applicationContext.getInjector().getInstanceWithClassName( "Array<String>", "stringCollection" );
		
		Assert.isInstanceOf( intCollection, Array );
		Assert.isInstanceOf( uintCollection, Array );
		Assert.isInstanceOf( stringCollection, Array );
		
		Assert.equals( intCollection, uintCollection );
		Assert.notEquals( intCollection, stringCollection );
	}
	
	@Test( "test map-type attribute with instance" )
	public function testMapTypeWithInstance() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/mapTypeWithInstance.xml", "StaticXmlCompiler_testMapTypeWithInstance" );
		code.execute();
		
		var intInstance = code.applicationContext.getInjector().getInstanceWithClassName( "hex.mock.IMockInterfaceWithGeneric<Int>", "intInstance" );
		var uintInstance = code.applicationContext.getInjector().getInstanceWithClassName( "hex.mock.IMockInterfaceWithGeneric<UInt>", "intInstance" );
		var stringInstance = code.applicationContext.getInjector().getInstanceWithClassName( "hex.mock.IMockInterfaceWithGeneric<String>", "stringInstance" );

		Assert.isInstanceOf( intInstance, MockClassWithGeneric );
		Assert.isInstanceOf( uintInstance, MockClassWithGeneric );
		Assert.isInstanceOf( stringInstance, MockClassWithGeneric );
		
		Assert.equals( intInstance, uintInstance );
		Assert.notEquals( intInstance, stringInstance );
	}
	
	@Test( "test building class reference" )
	public function testBuildingClassReference() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/classReference.xml", "StaticXmlCompiler_testBuildingClassReference" );
		code.execute();

		Assert.isInstanceOf( code.locator.RectangleClass, Class );
		Assert.isInstanceOf( Type.createInstance( code.locator.RectangleClass, [] ), MockRectangle );

		Assert.isInstanceOf( code.locator.classContainer.AnotherRectangleClass, Class );
		Assert.isInstanceOf( Type.createInstance( code.locator.classContainer.AnotherRectangleClass, [] ), MockRectangle );

		Assert.equals( code.locator.RectangleClass, code.locator.classContainer.AnotherRectangleClass );
	}
	
	@Test( "test static-ref" )
	public function testStaticRef() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/staticRef.xml", "StaticXmlCompiler_testStaticRef" );
		code.execute();

		Assert.equals( code.locator.constant, MockClass.MESSAGE_TYPE );
	}
	
	@Test( "test static-ref property" )
	public function testStaticProperty() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/staticRefProperty.xml", "StaticXmlCompiler_testStaticProperty" );
		code.execute();

		Assert.equals( MockClass.MESSAGE_TYPE, code.locator.object.property );
		Assert.equals( MockClass, code.locator.object2.property );
	}
	
	@Test( "test static-ref argument" )
	public function testStaticArgument() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/staticRefArgument.xml", "StaticXmlCompiler_testStaticArgument" );
		code.execute();

		Assert.equals( code.locator.instance.constant, MockClass.MESSAGE_TYPE );
	}
	
	@Test( "test static-ref argument on method-call" )
	public function testStaticArgumentOnMethodCall() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/staticRefArgumentOnMethodCall.xml", "StaticXmlCompiler_testStaticArgumentOnMethodCall" );
		code.execute();

		Assert.equals( MockMethodCaller.staticVar, code.locator.instance.argument );
	}
	
	@Test( "test map-type attribute" )
	public function testMapTypeAttribute() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/mapTypeAttribute.xml", "StaticXmlCompiler_testMapTypeAttribute" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClass );
		Assert.isInstanceOf( code.locator.instance, IMockInterface );
		Assert.equals( code.locator.instance, code.applicationContext.getInjector().getInstance( IMockInterface, "instance" ) );
		
		Assert.isNotNull( code.locator.instance2 );
		Assert.isInstanceOf( code.locator.instance2, MockClass );
		Assert.equals( code.locator.instance2, code.applicationContext.getInjector().getInstanceWithClassName( 'hex.mock.MockModuleWithInternalType.GetInfosInternalTypedef', "instance2" ) );
	}
	
	@Test( "test multi map-type attributes" )
	public function testMultiMapTypeAttributes() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/static/multiMapTypeAttributes.xml", "StaticXmlCompiler_testMultiMapTypeAttributes" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClass );
		Assert.isInstanceOf( code.locator.instance, IMockInterface );
		Assert.isInstanceOf( code.locator.instance, IAnotherMockInterface );
		
		Assert.equals( code.locator.instance, code.applicationContext.getInjector().getInstance( IMockInterface, "instance" ) );
		Assert.equals( code.locator.instance, code.applicationContext.getInjector().getInstance( IAnotherMockInterface, "instance" ) );
		
		Assert.equals( code.locator.f, code.applicationContext.getInjector().getInstanceWithClassName( "String->String", "f" ) );
		Assert.equals( code.locator.f, code.applicationContext.getInjector().getInstanceWithClassName( "hex.mock.MockModuleWithInternalType.FunctionSignature", "f" ) );
	
		Assert.equals( code.locator.f2, code.applicationContext.getInjector().getInstanceWithClassName( "String->String", "f2" ) );
		Assert.equals( code.locator.f2, code.applicationContext.getInjector().getInstanceWithClassName( "hex.mock.MockModuleWithInternalType.FunctionSignature", "f2" ) );
		
		Assert.equals( code.locator.f, code.locator.instanceWithSubType.toInject1 );
		Assert.equals( code.locator.f2, code.locator.instanceWithSubType.toInject2 );
		Assert.equals( code.locator.f, code.locator.instanceWithSubType.toInject1b );
		Assert.equals( code.locator.f2, code.locator.instanceWithSubType.toInject2b );
		Assert.equals( code.locator.f, code.locator.instanceWithSubType.toInject1c );
		Assert.equals( code.locator.f2, code.locator.instanceWithSubType.toInject2c );
	}
	
	@Test( "test building Map with class reference" )
	public function testBuildingMapWithClassReference() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/hashmapWithClassReference.xml", "StaticXmlCompiler_testBuildingMapWithClassReference" );
		code.execute();

		Assert.equals( IMockInterface, code.locator.map.getKeys()[ 0 ] );
		Assert.equals( MockClass, code.locator.map.get( IMockInterface ) );
	}
	
	@Test( "test building two modules listening each other" )
	public function testBuildingTwoModulesListeningEachOther() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/twoModulesListeningEachOther.xml", "StaticXmlCompiler_testBuildingTwoModulesListeningEachOther" );
		code.execute();

		Assert.isNotNull( code.locator.chat );
		Assert.isNull( code.locator.chat.translatedMessage );
		Assert.isNotNull( code.locator.translation );

		code.locator.chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "Hello", code.locator.chat.translatedMessage );
	}
	
	@Test( "test building two modules listening each other with adapter" )
	public function testBuildingTwoModulesListeningEachOtherWithAdapter() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/twoModulesListeningEachOtherWithAdapter.xml", "StaticXmlCompiler_testBuildingTwoModulesListeningEachOtherWithAdapter" );
		code.execute();

		Assert.isNotNull( code.locator.chat );
		Assert.isNull( code.locator.chat.translatedMessage );
		Assert.isNotNull( code.locator.translation );

		code.locator.chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "Hello", code.locator.chat.translatedMessage );
		Assert.isInstanceOf( code.locator.chat.date, Date );
	}
	
	@Test( "test building two modules listening each other with adapter and injection" )
	public function testBuildingTwoModulesListeningEachOtherWithAdapterAndInjection() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/twoModulesListeningEachOtherWithAdapterAndInjection.xml", "StaticXmlCompiler_testBuildingTwoModulesListeningEachOtherWithAdapterAndInjection" );
		code.execute();

		Assert.isNotNull( code.locator.chat );
		Assert.isNotNull( code.locator.receiver );
		Assert.isNotNull( code.locator.parser );

		code.locator.chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "BONJOUR", code.locator.receiver.message );
	}
	
	@Test( "test domain dispatch after module initialisation" )
	public function testDomainDispatchAfterModuleInitialisation() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/domainDispatchAfterModuleInitialisation.xml", "StaticXmlCompiler_testDomainDispatchAfterModuleInitialisation" );
		code.execute();

		Assert.isNotNull( code.locator.sender );
		Assert.isNotNull( code.locator.receiver );
		Assert.equals( "hello receiver", code.locator.receiver.message );
	}
	
	@Async( "test event adapter strategy macro" )
	public function testEventAdapterStrategyMacro() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/eventAdapterStrategyMacro.xml", "StaticXmlCompiler_testEventAdapterStrategyMacro" );
		code.execute();

		Assert.isNotNull( code.locator.sender );
		Assert.isNotNull( code.locator.receiver );
		Timer.delay( MethodRunner.asyncHandler( this._onEventAdapterStrategyMacro ), 350 );
	}
	
	function _onEventAdapterStrategyMacro()
	{
		var receiver : MockReceiverModule = this._locate( "StaticXmlCompiler_testEventAdapterStrategyMacro", "receiver" );
		Assert.equals( "HELLO RECEIVER:HTTP://GOOGLE.COM", receiver.message );
	}
	
	@Test( "test target sub property" )
	public function testTargetSubProperty() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/targetSubProperty.xml", "StaticXmlCompiler_testTargetSubProperty" );
		code.execute();

		Assert.isInstanceOf( code.locator.mockObject, MockObjectWithRegtangleProperty );
		Assert.equals( 1.5, code.locator.mockObject.rectangle.x );
	}
	
	@Test( "test building mapping configuration" )
	public function testBuildingMappingConfiguration() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/mappingConfiguration.xml", "StaticXmlCompiler_testBuildingMappingConfiguration" );
		code.execute();

		Assert.isInstanceOf( code.locator.config, MappingConfiguration );

		var injector = new Injector();
		code.locator.config.configure( injector, null );

		Assert.isInstanceOf( injector.getInstance( IMockInterface ), MockClass );
		Assert.isInstanceOf( injector.getInstance( IAnotherMockInterface ), AnotherMockClass );
		Assert.equals( code.locator.instance, injector.getInstance( IAnotherMockInterface ) );
	}
	
	@Test( "test building mapping configuration with map names" )
	public function testBuildingMappingConfigurationWithMapNames() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/mappingConfigurationWithMapNames.xml", "StaticXmlCompiler_testBuildingMappingConfigurationWithMapNames" );
		code.execute();

		Assert.isInstanceOf( code.locator.config, MappingConfiguration );

		var injector = new Injector();
		code.locator.config.configure( injector, null );

		Assert.isInstanceOf( injector.getInstance( IAnotherMockInterface, "name1" ),  MockClass );
		Assert.isInstanceOf( injector.getInstance( IAnotherMockInterface, "name2" ), AnotherMockClass );
	}
	
	@Test( "test building mapping configuration with singleton" )
	public function testBuildingMappingConfigurationWithSingleton() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/mappingConfigurationWithSingleton.xml", "StaticXmlCompiler_testBuildingMappingConfigurationWithSingleton" );
		code.execute();


		Assert.isInstanceOf( code.locator.config, MappingConfiguration );

		var injector = new Injector();
		code.locator.config.configure( injector, null );

		var instance1 = injector.getInstance( IAnotherMockInterface, "name1" );
		Assert.isInstanceOf( instance1,  MockClass );
		
		var copyOfInstance1 = injector.getInstance( IAnotherMockInterface, "name1" );
		Assert.isInstanceOf( copyOfInstance1,  MockClass, "" );
		Assert.equals( instance1, copyOfInstance1 );
		
		var instance2 = injector.getInstance( IAnotherMockInterface, "name2" );
		Assert.isInstanceOf( instance2, AnotherMockClass );
		
		var copyOfInstance2 = injector.getInstance( IAnotherMockInterface, "name2" );
		Assert.isInstanceOf( copyOfInstance2,  AnotherMockClass );
		Assert.notEquals( instance2, copyOfInstance2 );
	}
	
	@Test( "test building mapping configuration with inject-into" )
	public function testBuildingMappingConfigurationWithInjectInto() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/mappingConfigurationWithInjectInto.xml", "StaticXmlCompiler_testBuildingMappingConfigurationWithInjectInto" );
		code.execute();

		Assert.isInstanceOf( code.locator.config, MappingConfiguration );

		var injector = new Injector();
		var domain = Domain.getDomain( 'StaticXmlCompilerTest.testBuildingMappingConfigurationWithInjectInto' );
		injector.mapToValue( Domain, domain );
		
		code.locator.config.configure( injector, null );

		var mock0 = injector.getInstance( IMockInjectee, "name1" );
		Assert.isInstanceOf( mock0,  MockInjectee );
		Assert.equals( domain, mock0.domain  );
		
		var mock1 = injector.getInstance( IMockInjectee, "name2" );
		Assert.isInstanceOf( mock1, MockInjectee );
		Assert.equals( domain, mock1.domain );
	}
	
	@Test( "test static-ref with factory" )
	public function testStaticRefWithFactory() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/staticRefFactory.xml", "StaticXmlCompiler_testStaticRefWithFactory" );
		code.execute();
		
		Assert.isNotNull( code.locator.div );
		Assert.isInstanceOf( code.locator.div, MockDocument );
	}

	@Test( "test module listening service" )
	public function testModuleListeningService() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/moduleListeningService.xml", "StaticXmlCompiler_testModuleListeningService" );
		code.execute();
		
		Assert.isNotNull( code.locator.myService );
		Assert.isNotNull( code.locator.myModule );

		var booleanVO = new MockBooleanVO( true );
		code.locator.myService.setBooleanVO( booleanVO );
		Assert.isTrue( code.locator.myModule.getBooleanValue() );
	}
	
	@Test( "test module listening service with map-type" )
	public function testModuleListeningServiceWithMapType() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/moduleListeningServiceWithMapType.xml", "StaticXmlCompiler_testModuleListeningServiceWithMapType" );
		code.execute();

		Assert.isNotNull( code.locator.myService );
		Assert.isNotNull( code.locator.myModule );

		var booleanVO = new MockBooleanVO( true );
		code.locator.myService.setBooleanVO( booleanVO );
		Assert.isTrue( code.locator.myModule.getBooleanValue() );
		
		Assert.equals( code.locator.myService, code.applicationContext.getInjector().getInstance( IMockStubStatefulService, "myService" ) );
	}
	
	@Test( "test module listening service with strategy and module injection" )
	public function testModuleListeningServiceWithStrategyAndModuleInjection() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/moduleListeningServiceWithStrategyAndModuleInjection.xml", "StaticXmlCompiler_testModuleListeningServiceWithStrategyAndModuleInjection" );
		code.execute();

		Assert.isNotNull( code.locator.myService );
		Assert.isNotNull( code.locator.myModule );

		var intVO = new MockIntVO( 7 );
		code.locator.myService.setIntVO( intVO );
		Assert.equals( 3.5, code.locator.myModule.getFloatValue() );
	}
	
	@Test( "test module listening service with strategy and context injection" )
	public function testModuleListeningServiceWithStrategyAndContextInjection() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/moduleListeningServiceWithStrategyAndContextInjection.xml", "StaticXmlCompiler_testModuleListeningServiceWithStrategyAndContextInjection" );
		code.execute();

		Assert.isNotNull( code.locator.mockDividerHelper );
		Assert.isNotNull( code.locator.myService );
		Assert.isNotNull( code.locator.myModuleA );
		Assert.isNotNull( code.locator.myModuleB );

		code.locator.myService.setIntVO( new MockIntVO( 7 ) );
		Assert.equals( 3.5, ( code.locator.myModuleA.getFloatValue() ), "" );

		code.locator.myService.setIntVO( new MockIntVO( 9 ) );
		Assert.equals( 4.5, ( code.locator.myModuleB.getFloatValue() ), "" );
	}

	@Async( "test EventTrigger" )
	public function testEventTrigger() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/eventTrigger.xml", "StaticXmlCompiler_testEventTrigger" );
		code.execute();
		
		Assert.isNotNull( code.locator.eventTrigger );
		Assert.isNotNull( code.locator.chat );
		Assert.isNotNull( code.locator.receiver );
		Assert.isNotNull( code.locator.parser );

		Timer.delay( MethodRunner.asyncHandler( this._onCompleteHandlerEventTrigger ), 500 );
		code.locator.chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "bonjour" ] );
	}
	
	function _onCompleteHandlerEventTrigger() : Void
	{
		var receiver : MockReceiverModule = this._locate( "StaticXmlCompiler_testEventTrigger", "receiver" );
		Assert.equals( "BONJOUR:HTTP://GOOGLE.COM", receiver.message, "" );
	}
	
	@Async( "test EventProxy" )
	public function testEventProxy() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/eventProxy.xml", "StaticXmlCompiler_testEventProxy" );
		code.execute();

		Assert.isNotNull( code.locator.eventProxy );
		Assert.isNotNull( code.locator.chat );
		Assert.isNotNull( code.locator.receiver );
		Assert.isNotNull( code.locator.eventProxy );
		Assert.isNotNull( code.locator.parser );

		Timer.delay( MethodRunner.asyncHandler( this._onCompleteHandlerEventProxy ), 500 );
		code.locator.chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "bonjour" ] );
	}
	
	function _onCompleteHandlerEventProxy() : Void
	{
		var receiver : MockReceiverModule = this._locate( "StaticXmlCompiler_testEventProxy", "receiver" );
		Assert.equals( "BONJOUR:HTTP://GOOGLE.COM", receiver.message, "" );
	}
	
	function _locate( contextName : String, key : String ) : Dynamic
	{
		return this._applicationAssembler.getApplicationContext( contextName, ApplicationContext ).getCoreFactory().locate( key );
	}
	
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
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/testMockObjectWithAnnotation.xml", "StaticXmlCompiler_testMockObjectWithAnnotation" );
		var annotationProvider : IAnnotationProvider = code.applicationContext.getInjector().getInstance( IAnnotationProvider );

		annotationProvider.registerMetaData( "color", this.getColorByName );
		annotationProvider.registerMetaData( "language", this.getText );
		
		code.execute();
		
		Assert.equals( 0xffffff, code.locator.mockObjectWithAnnotation.colorTest, "color should be the same" );
		Assert.equals( "Bienvenue", code.locator.mockObjectWithAnnotation.languageTest, "text should be the same" );
		Assert.isNull( code.locator.mockObjectWithAnnotation.propWithoutMetaData, "property should be null" );
	}
	
	@Test( "Test AnnotationProvider with inheritance" )
	public function testAnnotationProviderWithInheritance() : Void
	{
		var assembler = new ApplicationAssembler();
		this._applicationAssembler = assembler;
		
		var code = StaticXmlCompiler.compile( assembler, "context/testMockObjectWithAnnotation.xml", "StaticXmlCompiler_testAnnotationProviderWithInheritance" );
		code.execute();
		
		var annotationProvider : IAnnotationProvider = code.applicationContext.getInjector().getInstance( IAnnotationProvider );
		annotationProvider.registerMetaData( "color", this.getColorByName );
		annotationProvider.registerMetaData( "language", this.getText );
		
		var code2 = StaticXmlCompiler.extend( assembler, code, "context/testAnnotationProviderWithInheritance.xml" );
		code2.execute();
		
		var mockObjectWithMetaData = code2.locator.mockObjectWithAnnotation;
		
		Assert.equals( 0xffffff, mockObjectWithMetaData.colorTest, "color should be the same" );
		Assert.equals( "Bienvenue", mockObjectWithMetaData.languageTest, "text should be the same" );
		Assert.isNull( mockObjectWithMetaData.propWithoutMetaData, "property should be null" );
		
		//
		var provider = code2.locator.module.getAnnotationProvider();
		code2.locator.module.buildComponents();

		Assert.equals( 0xffffff, code2.locator.module.mockObjectWithMetaData.colorTest, "color should be the same" );
		Assert.equals( "Bienvenue", code2.locator.module.mockObjectWithMetaData.languageTest, "text should be the same" );
		Assert.isNull( code2.locator.module.anotherMockObjectWithMetaData.languageTest, "property should be null when class is not implementing IAnnotationParsable" );
		
		provider.registerMetaData( "language", this.getAnotherText );
		code2.locator.module.buildComponents();
		
		Assert.equals( 0xffffff, code2.locator.module.mockObjectWithMetaData.colorTest, "color should be the same" );
		Assert.equals( "anotherText", code2.locator.module.mockObjectWithMetaData.languageTest, "text should be the same" );
		Assert.isNull( code2.locator.module.anotherMockObjectWithMetaData.languageTest, "property should be null when class is not implementing IAnnotationParsable" );
	}
	
	@Test( "Test Macro with annotation" )
	public function testMacroWithAnnotation() : Void
	{
		MockMacroWithAnnotation.lastResult = null;
		MockCommandWithAnnotation.lastResult = null;
		MockAsyncCommandWithAnnotation.lastResult = null;
		
		var applicationAssembler = new ApplicationAssembler();
        var applicationContext = applicationAssembler.getApplicationContext( "StaticXmlCompiler_testMacroWithAnnotation", ApplicationContext );
        var injector = applicationContext.getInjector();
        
        var annotationProvider = AnnotationProvider.getAnnotationProvider( applicationContext.getDomain() );
        annotationProvider.registerMetaData( "Value", this._getValue );
		
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/macroWithAnnotation.xml", "StaticXmlCompiler_testMacroWithAnnotation" );
		code.execute();
		
		var annotationProvider : IAnnotationProvider = this._applicationAssembler.getApplicationContext( "StaticXmlCompiler_testMacroWithAnnotation", ApplicationContext ).getInjector().getInstance( IAnnotationProvider );

		Assert.equals( "value", MockMacroWithAnnotation.lastResult, "text should be the same" );
		Assert.equals( "value", MockCommandWithAnnotation.lastResult, "text should be the same" );
		Assert.equals( "value", MockAsyncCommandWithAnnotation.lastResult, "text should be the same" );
	}

	function _getValue( key : String ) return "value";
	
	@Test( "test trigger injection" )
	public function testTriggerInjection() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/triggerInjection.xml", "StaticXmlCompiler_testTriggerInjection" );
		code.execute();

		Assert.isInstanceOf( code.locator.model, MockWeatherModel );
		
		code.locator.model.temperature.trigger( 13 );
		code.locator.model.weather.trigger( 'sunny' );
		
		Assert.equals( 13, code.locator.module.temperature );
		Assert.equals( 'sunny', code.locator.module.weather );
	}
	
	//
	@Test( "test if attribute" )
	public function testIfAttribute() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/static/ifAttribute.xml", "StaticXmlCompiler_testIfAttribute", null, [ "prodz2" => true, "testing2" => false, "releasing2" => false ] );
		code.execute();
		
		Assert.equals( "hello prod", code.locator.message );
	}
	
	@Test( "test include with if attribute" )
	public function testIncludeWithIfAttribute() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/static/includeWithIfAttribute.xml", "StaticXmlCompiler_testIncludeWithIfAttribute", null, [ "prodz2" => true, "testing2" => false, "releasing2" => false ] );
		code.execute();
		
		Assert.equals( "hello prod", code.locator.message );
	}

	@Test( "test include fails with if attribute" )
	public function testIncludeFailsWithIfAttribute() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/static/includeWithIfAttribute.xml", "StaticXmlCompiler_testIncludeFailsWithIfAttribute", null, [ "prodz2" => false, "testing2" => true, "releasing2" => true ] );
		code.execute();
		
		var coreFactory = this._applicationAssembler.getApplicationContext( "BasicStaticXmlCompiler_testIncludeFailsWithIfAttribute", ApplicationContext ).getCoreFactory();
		Assert.methodCallThrows( NoSuchElementException, coreFactory, coreFactory.locate, [ "message" ], "'NoSuchElementException' should be thrown" );
	}
	
	@Test( "test file preprocessor with Xml file" )
	public function testFilePreprocessorWithXmlFile() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/preprocessor.xml", "StaticXmlCompiler_testFilePreprocessorWithXmlFile", 
															[	"hello" 		=> "bonjour",
																					"contextName" 	=> 'applicationContext',
																					"context" 		=> 'name="${contextName}"',
																					"node" 			=> '<msg id="message" value="${hello}"/>' ] );
		code.execute();
		
		Assert.equals( "bonjour", code.locator.message, "message value should equal 'bonjour'" );
	}

	@Test( "test file preprocessor with Xml file and include" )
	public function testFilePreprocessorWithXmlFileAndInclude() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/preprocessorWithInclude.xml", "StaticXmlCompiler_testFilePreprocessorWithXmlFileAndInclude", 
																				[	"hello" 		=> "bonjour",
																					"contextName" 	=> 'applicationContext',
																					"context" 		=> 'name="${contextName}"',
																					"node" 			=> '<msg id="message" value="${hello}"/>' ] );
		code.execute();
		
		try
        {
			Assert.equals( "bonjour", code.locator.message, "message value should equal 'bonjour'" );
		}
		catch ( e : Exception )
        {
            Assert.fail( e.message, "Exception on this._builderFactory.getCoreFactory().locate( \"message\" ) call" );
        }
	}
	
	@Test( "test parsing twice" )
	public function testParsingTwice() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/parsingOnce.xml", "StaticXmlCompiler_testParsingTwice" );
		var code2 = StaticXmlCompiler.extend( this._applicationAssembler, code, "context/xml/parsingTwice.xml" );

		code.execute();
		Assert.isInstanceOf( code.locator.rect0, MockRectangle );
		Assert.equals( 10, code.locator.rect0.x );
		Assert.equals( 20, code.locator.rect0.y );
		Assert.equals( 30, code.locator.rect0.width );
		Assert.equals( 40, code.locator.rect0.height );

		code2.execute();
		Assert.isInstanceOf( code2.locator.rect1, MockRectangle );
		Assert.equals( 50, code2.locator.rect1.x );
		Assert.equals( 60, code2.locator.rect1.y );
		Assert.equals( 70, code2.locator.rect1.width );
		Assert.equals( 40, code2.locator.rect1.height );
	}
	
	@Test( "test build domain" )
	public function testBuildDomain() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/buildDomain.xml", "StaticXmlCompiler_testBuildDomain" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.applicationDomain, Domain );
	}
	
	@Test( "test recursive static calls" )
	public function testRecursiveStaticCalls() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/instanceWithStaticMethodAndArguments.xml", "StaticXmlCompiler_testRecursiveStaticCalls" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.rect, MockRectangle );
		Assert.equals( 10, code.locator.rect.x );
		Assert.equals( 20, code.locator.rect.y );
		Assert.equals( 30, code.locator.rect.width );
		Assert.equals( 40, code.locator.rect.height );
		
		var code2 = StaticXmlCompiler.extend( this._applicationAssembler, code, "context/xml/recursiveStaticCalls.xml" );
		code2.execute();
		
		Assert.isInstanceOf( code2.locator.rect2, MockRectangle );
		Assert.equals( 10, code2.locator.rect2.x );
		Assert.equals( 20, code2.locator.rect2.y );
		Assert.equals( 30, code2.locator.rect2.width );
		Assert.equals( 40, code2.locator.rect2.height );
	}
	
	@Test( "test runtime arguments" )
	public function testRuntimeArguments() : Void
	{
		var code = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/runtimeArguments.xml", "StaticXmlCompiler_testRuntimeArguments" );
		code.execute( { x:10, y: 20, p: new hex.structures.Point( 30, 40 ) } );
		
		Assert.isInstanceOf( code.locator.size, Size );
		Assert.equals( 10, code.locator.size.width );
		Assert.equals( 20, code.locator.size.height );
		
		Assert.isInstanceOf( code.locator.anotherSize, Size );
		Assert.equals( 30, code.locator.anotherSize.width );
		Assert.equals( 40, code.locator.anotherSize.height );
	}
	
	@Test( "test module listening service with 2 passes" )
	public function testModuleListeningServiceWith2Passes() : Void
	{
		var code1 = StaticXmlCompiler.compile( this._applicationAssembler, "context/xml/serviceToBeListened.xml", "StaticXmlCompiler_testModuleListeningServiceWith2Passes" );
		code1.execute();
		
		var code = StaticXmlCompiler.extend( this._applicationAssembler, code1, "context/xml/moduleListener.xml" );
		code.execute();
		
		Assert.isNotNull( code.locator.myService );
		Assert.isNotNull( code.locator.myModule );

		var booleanVO = new MockBooleanVO( true );
		code.locator.myService.setBooleanVO( booleanVO );
		Assert.isTrue( code.locator.myModule.getBooleanValue() );
	}
}