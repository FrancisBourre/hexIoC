package hex.ioc.parser.xml;

import haxe.Timer;
import hex.collection.HashMap;
import hex.config.stateful.ServiceLocator;
import hex.di.IDependencyInjector;
import hex.domain.ApplicationDomainDispatcher;
import hex.event.Dispatcher;
import hex.event.EventProxy;
import hex.inject.Injector;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.assembler.IApplicationAssembler;
import hex.ioc.core.BuilderFactory;
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
import hex.structures.Point;
import hex.structures.Size;
import hex.unittest.assertion.Assert;
import hex.unittest.runner.MethodRunner;

import hex.ioc.parser.xml.mock.MockRectangleFactory;
import hex.ioc.parser.xml.mock.MockPointFactory;
import hex.ioc.parser.xml.mock.MockXMLParser;
import hex.ioc.parser.xml.mock.MockChatAdapterStrategy;
import hex.ioc.parser.xml.mock.MockChatEventAdapterStrategyWithInjection;
import hex.ioc.parser.xml.mock.MockStubStatefulService;
import hex.ioc.parser.xml.mock.MockIntDividerEventAdapterStrategy;
import hex.ioc.parser.xml.mock.MockChatEventAdapterStrategyMacro;
import hex.ioc.parser.xml.mock.MockChatAdapterStrategyMacro;

/**
 * ...
 * @author Francis Bourre
 */
class ObjectXMLParserTest
{
	var _contextParser 				: ApplicationXMLParser;
	var _applicationContext 		: ApplicationContext;
	var _builderFactory 			: BuilderFactory;
	var _applicationAssembler 		: IApplicationAssembler;
		
	@Before
	public function setUp() : Void
	{
		this._applicationAssembler 	= new ApplicationAssembler();
		this._applicationContext 	= this._applicationAssembler.getApplicationContext( "applicationContext" );
		this._builderFactory 		= this._applicationAssembler.getBuilderFactory( this._applicationContext );
	}

	@After
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.getInstance().clear();
		this._applicationAssembler.release();
	}
		
	function _build( xml : Xml, applicationContext : ApplicationContext = null ) : Void
	{
		this._contextParser = new ApplicationXMLParser();
		//this._contextParser.parse( applicationContext != null ? applicationContext : this._applicationContext, this._applicationAssembler, xml );
		this._contextParser.parse( this._applicationAssembler, xml );
		this._applicationAssembler.buildEverything();
	}
	
	@Test( "test building String" )
	public function testBuildingString() : Void
	{
		var source : String = '
		<root name="applicationContext">
			<test id="s" value="hello"/>
		</root>';
		
		
		var xml : Xml = Xml.parse( source );
		this._build( xml );
		
		var s : String = this._builderFactory.getCoreFactory().locate( "s" );
		Assert.equals( "hello", s, "" );
	}
	
	@Test( "test building anonymous object" )
	public function testBuildingAnonymousObject() : Void
	{
		var source : String = '
		<root name="applicationContext">
			<test id="obj" type="Object">
				<property name="name" value="Francis"/>
				<property name="age" type="Int" value="44"/>
				<property name="height" type="Float" value="1.75"/>
				<property name="isWorking" type="Bool" value="true"/>
				<property name="isSleeping" type="Bool" value="false"/>
			</test>
		</root>';
		
		
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
	
	@Test( "test building simple instance with arguments" )
	public function testBuildingSimpleInstanceWithArguments() : Void
	{
		var source : String = '
		<root name="applicationContext">
			<bean id="size" type="hex.structures.Size">
				<argument type="Int" value="10"/>
				<argument type="Int" value="20"/>
			</bean>
		</root>';
			
		var xml : Xml = Xml.parse( source );
		this._build( xml );

		var size : Size = this._builderFactory.getCoreFactory().locate( "size" );
		Assert.isInstanceOf( size, Size, "" );
		Assert.equals( 10, size.width, "" );
		Assert.equals( 20, size.height, "" );
	}
	
	@Test( "test building multiple instances with references" )
	public function testBuildingMultipleInstancesWithReferences() : Void
	{
		var source : String = '
		<root name="applicationContext">
			<rectangle id="rect" type="hex.ioc.parser.xml.mock.MockRectangle">
				<argument ref="rectPosition.x"/>
				<argument ref="rectPosition.y"/>
				<property name="size" ref="rectSize" />
			</rectangle>
			
			<size id="rectSize" type="hex.structures.Point">
				<argument type="Int" value="30"/>
				<argument type="Int" value="40"/>
			</size>
			
			<position id="rectPosition" type="hex.structures.Point">
				<property type="Int" name="x" value="10"/>
				<property type="Int" name="y" value="20"/>
			</position>
		</root>';
		
		var xml : Xml = Xml.parse( source );
		this._build( xml );

		var rectSize : Point = this._builderFactory.getCoreFactory().locate( "rectSize" );
		Assert.isInstanceOf( rectSize, Point, "" );
		Assert.equals( 30, rectSize.x, "" );
		Assert.equals( 40, rectSize.y, "" );

		var rectPosition : Point = this._builderFactory.getCoreFactory().locate( "rectPosition" );
		Assert.isInstanceOf( rectPosition, Point, "" );
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
		var source : String = '
		<root name="applicationContext">
			<rectangle id="rect" type="hex.ioc.parser.xml.mock.MockRectangle">
				<property name="size" ref="rectSize" />
				<method-call name="offsetPoint">
					<argument ref="rectPosition"/>
				</method-call></rectangle>
			
			<size id="rectSize" type="hex.structures.Point">
				<argument type="Int" value="30"/>
				<argument type="Int" value="40"/>
			</size>
			
			<position id="rectPosition" type="hex.structures.Point">
				<property type="Int" name="x" value="10"/>
				<property type="Int" name="y" value="20"/>
			</position>
			
			<rectangle id="anotherRect" type="hex.ioc.parser.xml.mock.MockRectangle">
				<property name="size" ref="rectSize" />
				<method-call name="reset"/>
			</rectangle>
		</root>';
		
		var xml : Xml = Xml.parse( source );
		this._build( xml );

		var rectSize : Point = this._builderFactory.getCoreFactory().locate( "rectSize" );
		Assert.isInstanceOf( rectSize, Point, "" );
		Assert.equals( 30, rectSize.x, "" );
		Assert.equals( 40, rectSize.y, "" );

		var rectPosition : Point = this._builderFactory.getCoreFactory().locate( "rectPosition" );
		Assert.isInstanceOf( rectPosition, Point, "" );
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
	
	@Test( "test building singleton instance" )
	public function testBuildingSingletonInstance() : Void
	{
		var source : String = '
		<root name="applicationContext">
			<gateway id="gateway" value="http://localhost/amfphp/gateway.php"/>
			
			<service id="service" type="hex.ioc.parser.xml.mock.MockServiceProvider" singleton-access="getInstance">
				<method-call name="setGateway">
					<argument ref="gateway" />
				</method-call>
			</service>

		</root>';
		
		var xml : Xml = Xml.parse( source );
		this._build( xml );

		var service : MockServiceProvider = this._builderFactory.getCoreFactory().locate( "service" );
		Assert.isInstanceOf( service, MockServiceProvider, "" );
		Assert.equals( "http://localhost/amfphp/gateway.php", MockServiceProvider.getInstance().getGateway(), "" );
	}
	
	@Test( "test factory with static method" )
	public function testFactoryWithStaticMethod() : Void
	{
		var source : String = '
		<root name="applicationContext">
			<rectangle id="rect" type="hex.ioc.parser.xml.mock.MockRectangleFactory" factory="getRectangle">
				<argument type="Int" value="10"/><argument type="Int" value="20"/>
				<argument type="Int" value="30"/><argument type="Int" value="40"/>
			</rectangle>
		</root>';
		
		var xml : Xml = Xml.parse( source );
		this._build( xml );

		var rect : MockRectangle = this._builderFactory.getCoreFactory().locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle, "" );
		Assert.equals( 10, rect.x, "" );
		Assert.equals( 20, rect.y, "" );
		Assert.equals( 30, rect.width, "" );
		Assert.equals( 40, rect.height, "" );
	}
	
	@Test( "test factory with singleton" )
	public function testFactoryWithSingleton() : Void
	{
		var source : String = '
		
		<root name="applicationContext">
			<point id="point" type="hex.ioc.parser.xml.mock.MockPointFactory" singleton-access="getInstance" factory="getPoint">
				<argument type="Int" value="10"/>
				<argument type="Int" value="20"/>
			</point>
		</root>';
		
		var xml : Xml = Xml.parse( source );
		this._build( xml );

		var point : Point = this._builderFactory.getCoreFactory().locate( "point" );
		Assert.isInstanceOf( point, Point, "" );
		Assert.equals( 10, point.x, "" );
		Assert.equals( 20, point.y, "" );
	}
	
	@Test( "test building XML with parser class" )
	public function testBuildingXMLWithParserClass() : Void
	{
		var source : String = '
		<root name="applicationContext">

			<data id="fruits" type="XML" parser-class="hex.ioc.parser.xml.mock.MockXMLParser">
				<root>
					<node>orange</node>
					<node>apple</node>
					<node>banana</node>
				</root>
			</data>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );

		var fruits : Array<MockFruitVO> = this._builderFactory.getCoreFactory().locate( "fruits" );
		Assert.equals( 3, fruits.length, "" );

		var orange : MockFruitVO = fruits[0];
		var apple : MockFruitVO = fruits[1];
		var banana : MockFruitVO = fruits[2];

		Assert.equals( "orange", orange.toString(), "" );
		Assert.equals( "apple", apple.toString(), "" );
		Assert.equals( "banana", banana.toString(), "" );
	}
	
	@Test( "test Array ref" )
	public function testArrayRef() : Void
	{
		var source : String = '
		<root name="applicationContext">

			<collection id="fruits" type="Array">
				<argument ref="fruit0" />
				<argument ref="fruit1" />
				<argument ref="fruit2" />
			</collection>

			<fruit id="fruit0" type="hex.ioc.parser.xml.mock.MockFruitVO"><argument value="orange"/></fruit>
			<fruit id="fruit1" type="hex.ioc.parser.xml.mock.MockFruitVO"><argument value="apple"/></fruit>
			<fruit id="fruit2" type="hex.ioc.parser.xml.mock.MockFruitVO"><argument value="banana"/></fruit>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );

		var fruits : Array<MockFruitVO> = this._builderFactory.getCoreFactory().locate( "fruits" );
		Assert.equals( 3, fruits.length, "" );

		var orange 	: MockFruitVO = fruits[0];
		var apple 	: MockFruitVO = fruits[1];
		var banana 	: MockFruitVO = fruits[2];

		Assert.equals( "orange", orange.toString(), "" );
		Assert.equals( "apple", apple.toString(), "" );
		Assert.equals( "banana", banana.toString(), "" );
	}
	
	@Test( "test Map ref" )
	public function testMapRef() : Void
	{
		var source : String = '
		<root name="applicationContext">

			<collection id="fruits" type="hex.core.HashMap">
				<item> <key value="0"/> <value ref="fruit0"/></item>
				<item> <key type="Int" value="1"/> <value ref="fruit1"/></item>
				<item> <key ref="stubKey"/> <value ref="fruit2"/></item>
			</collection>

			<fruit id="fruit0" type="hex.ioc.parser.xml.mock.MockFruitVO"><argument value="orange"/></fruit>
			<fruit id="fruit1" type="hex.ioc.parser.xml.mock.MockFruitVO"><argument value="apple"/></fruit>
			<fruit id="fruit2" type="hex.ioc.parser.xml.mock.MockFruitVO"><argument value="banana"/></fruit>

			<point id="stubKey" type="hex.structures.Point"/>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );

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
	
	@Test( "test domain listening" )
	public function testDomainListening() : Void
	{
		var source : String = '
		<root name="applicationContext">

			<chat id="chat" type="hex.ioc.parser.xml.mock.MockChatModule">
				<listen ref="translation"/>
			</chat>

			<translation id="translation" type="hex.ioc.parser.xml.mock.MockTranslationModule">
				<listen ref="chat">
					<event static-ref="hex.ioc.parser.xml.mock.MockChatModule.TEXT_INPUT" method="onSomethingToTranslate"/>
				</listen>
			</translation>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );

		var chat : MockChatModule = this._builderFactory.getCoreFactory().locate( "chat" );
		Assert.isNotNull( chat, "" );
		Assert.isNull( chat.translatedMessage, "" );

		var translation : MockTranslationModule = this._builderFactory.getCoreFactory().locate( "translation" );
		Assert.isNotNull( translation, "" );

		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "Hello", chat.translatedMessage, "" );
	}
	
	@Test( "test domain listening with classAdapter" )
	public function testDomainListeningWithEventAdapter() : Void
	{
		var source : String = '
		<root name="applicationContext">

			<chat id="chat" type="hex.ioc.parser.xml.mock.MockChatModule">
				<listen ref="translation"/>
			</chat>

			<translation id="translation" type="hex.ioc.parser.xml.mock.MockTranslationModule">
				<listen ref="chat">
					<event static-ref="hex.ioc.parser.xml.mock.MockChatModule.TEXT_INPUT" method="onTranslateWithTime" strategy="hex.ioc.parser.xml.mock.MockChatAdapterStrategy"/>
				</listen>
			</translation>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );

		var chat : MockChatModule = this._builderFactory.getCoreFactory().locate( "chat" );
		Assert.isNotNull( chat, "" );
		Assert.isNull( chat.translatedMessage, "" );

		var translation : MockTranslationModule = this._builderFactory.getCoreFactory().locate( "translation" );
		Assert.isNotNull( translation, "" );

		chat.dispatchDomainEvent( MockChatModule.TEXT_INPUT, [ "Bonjour" ] );
		Assert.equals( "Hello", chat.translatedMessage, "" );
		Assert.isInstanceOf( chat.date, Date, "" );
	}
	
	@Test( "test domain listening with classAdapter and injection" )
	public function testDomainListeningWithClassAdapterAndInjection() : Void
	{
		var source : String = '
		<root name="applicationContext">

			<chat id="chat" type="hex.ioc.parser.xml.mock.MockChatModule"/>

			<receiver id="receiver" type="hex.ioc.parser.xml.mock.MockReceiverModule">
				<listen ref="chat">
					<event static-ref="hex.ioc.parser.xml.mock.MockChatModule.TEXT_INPUT" method="onMessage" strategy="hex.ioc.parser.xml.mock.MockChatEventAdapterStrategyWithInjection"/>
				</listen>
			</receiver>

			<parser id="parser" type="hex.ioc.parser.xml.mock.MockMessageParserModule" map-type="hex.ioc.parser.xml.mock.IMockMessageParserModule"/>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );

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
		var source : String = '
		<root name="applicationContext">

			<sender id="sender" type="hex.ioc.parser.xml.mock.MockSenderModule"/>

			<receiver id="receiver" type="hex.ioc.parser.xml.mock.MockReceiverModule">
				<listen ref="sender">
					<event static-ref="hex.ioc.parser.xml.mock.MockChatModule.TEXT_INPUT" method="onMessageEvent"/>
				</listen>
			</receiver>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );

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

		var applicationContextParent : ApplicationContext	= this._applicationAssembler.getApplicationContext( "applicationContextParent" );
		var applicationContextChild 	= this._applicationAssembler.getApplicationContext( "applicationContextChild" );
		var applicationContextSubChild 	= this._applicationAssembler.getApplicationContext( "applicationContextSubChild" );

		applicationContextParent.addChild( applicationContextChild );
		applicationContextChild.addChild( applicationContextSubChild );

		this._build( Xml.parse( subChildSource ), applicationContextSubChild );
		this._build( Xml.parse( childSource ), applicationContextChild );
		this._build( Xml.parse( parentSource ), applicationContextParent );

		var builderFactory : BuilderFactory;

		builderFactory = this._applicationAssembler.getBuilderFactory( applicationContextParent );
		var parentRectangle  : MockRectangle = builderFactory.getCoreFactory().locate( "rect0" );
		Assert.isInstanceOf( parentRectangle, MockRectangle, "" );
		Assert.equals( 10, parentRectangle.x, "" );
		Assert.equals( 20, parentRectangle.y, "" );
		Assert.equals( 30, parentRectangle.width, "" );
		Assert.equals( 110, parentRectangle.height, "" );

		builderFactory = this._applicationAssembler.getBuilderFactory( applicationContextChild );
		var childRectangle : MockRectangle = builderFactory.getCoreFactory().locate( "rect0" );
		Assert.isInstanceOf( childRectangle, MockRectangle, "" );
		Assert.equals( 40, childRectangle.x, "" );
		Assert.equals( 50, childRectangle.y, "" );
		Assert.equals( 60, childRectangle.width, "" );
		Assert.equals( 70, childRectangle.height, "" );

		builderFactory = this._applicationAssembler.getBuilderFactory( applicationContextSubChild );
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
	
	@Test( "test targeting sub property" )
	public function testTargetingSubProperty() : Void
	{
		var source : String = '
		<root name="applicationContext">

			<test id="mockObject" type="hex.ioc.parser.xml.mock.MockObjectWithRegtangleProperty">
				<property name="rectangle.x" type="Float" value="1.5"/>
			</test>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );

		var mockObject : MockObjectWithRegtangleProperty = this._builderFactory.getCoreFactory().locate( "mockObject" );
		Assert.isInstanceOf( mockObject, MockObjectWithRegtangleProperty, "" );
		Assert.equals( 1.5, mockObject.rectangle.x, "" );
	}
	
	@Test( "test building class reference" )
	public function testBuildingClassReference() : Void
	{
		var source : String = '
		<root name="applicationContext">

			<RectangleClass id="RectangleClass" type="Class" value="hex.ioc.parser.xml.mock.MockRectangle"/>
			
			<test id="classContainer" type="Object">
				<property name="AnotherRectangleClass" ref="RectangleClass"/>
			</test>
			
		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );

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
	
	@Test( "test building serviceLocator" )
	public function testBuildingServiceLocator() : Void
	{
		var source : String = '
		<root name="applicationContext">
		
			<serviceLocator id="serviceLocator" type="hex.config.stateful.ServiceLocator">
				<item> <key type="Class" value="hex.ioc.parser.xml.mock.IMockAmazonService"/> <value type="Class" value="hex.ioc.parser.xml.mock.MockAmazonService"/></item>
				<item> <key type="Class" value="hex.ioc.parser.xml.mock.IMockFacebookService"/> <value ref="facebookService"/></item>
			</serviceLocator>

			<facebookService id="facebookService" type="hex.ioc.parser.xml.mock.MockFacebookService"/>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );

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
		var source : String = '
		<root name="applicationContext">
		
			<serviceLocator id="serviceLocator" type="hex.config.stateful.ServiceLocator">
				<item map-name="amazon0"> <key type="Class" value="hex.ioc.parser.xml.mock.IMockAmazonService"/> <value type="Class" value="hex.ioc.parser.xml.mock.MockAmazonService"/></item>
				<item map-name="amazon1"> <key type="Class" value="hex.ioc.parser.xml.mock.IMockAmazonService"/> <value type="Class" value="hex.ioc.parser.xml.mock.AnotherMockAmazonService"/></item>
			</serviceLocator>
				
		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );

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
		var source0 : String = '
		<root name="applicationContext">

			<bean id="rect0" type="hex.ioc.parser.xml.mock.MockRectangle">
				<argument type="Int" value="10"/>
				<argument type="Int" value="20"/>
				<argument type="Int" value="30"/>
				<argument type="Int" value="40"/>
			</bean>

		</root>';

		var source1 : String = '
		<root name="applicationContext">

			<bean id="rect1" type="hex.ioc.parser.xml.mock.MockRectangle">
				<argument type="Int" value="50"/>
				<argument type="Int" value="60"/>
				<argument type="Int" value="70"/>
				<argument ref="rect0.height"/>
			</bean>

		</root>';

		this._build( Xml.parse( source0 ) );
		this._build( Xml.parse( source1 ) );

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
	
	@Test( "test listening service" )
	public function testListeningService() : Void
	{
		var source : String = '
		<root name="applicationContext">

			<service id="myService" type="hex.ioc.parser.xml.mock.MockStubStatefulService"/>

			<module id="myModule" type="hex.ioc.parser.xml.mock.MockModuleWithServiceCallback">
				<listen ref="myService">
					<event static-ref="hex.ioc.parser.xml.mock.MockStubStatefulService.BOOLEAN_VO_UPDATE" method="onBooleanServiceCallback"/>
				</listen>
			</module>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );

		var myService : IMockStubStatefulService = this._builderFactory.getCoreFactory().locate( "myService" );
		Assert.isNotNull( myService, "" );

		var myModule : MockModuleWithServiceCallback = this._builderFactory.getCoreFactory().locate( "myModule" );
		Assert.isNotNull( myModule, "" );

		var booleanVO = new MockBooleanVO( true );
		myService.setBooleanVO( booleanVO );
		Assert.isTrue( myModule.getBooleanValue(), "" );
	}
	
	@Test( "test listening service with strategy and module injection" )
	public function testListeningServiceWithStrategyAndModuleInjection() : Void
	{
		var source : String = '
		<root name="applicationContext">

			<service id="myService" type="hex.ioc.parser.xml.mock.MockStubStatefulService"/>

			<module id="myModule" type="hex.ioc.parser.xml.mock.MockModuleWithServiceCallback">
				<listen ref="myService">
					<event static-ref="hex.ioc.parser.xml.mock.MockStubStatefulService.INT_VO_UPDATE"
						   method="onFloatServiceCallback"
						   strategy="hex.ioc.parser.xml.mock.MockIntDividerEventAdapterStrategy"
						   injectedInModule="true"/>
				</listen>
			</module>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );

		var myService : IMockStubStatefulService = this._builderFactory.getCoreFactory().locate( "myService" );
		Assert.isNotNull( myService, "" );

		var myModule : MockModuleWithServiceCallback = this._builderFactory.getCoreFactory().locate( "myModule" );
		Assert.isNotNull( myModule, "" );

		var intVO = new MockIntVO( 7 );
		myService.setIntVO( intVO );
		Assert.equals( 3.5, ( myModule.getFloatValue() ), "" );
	}
	
	@Test( "test listening service with strategy and context injection" )
	public function testListeningServiceWithStrategyAndContextInjection() : Void
	{
		var source : String = '
		<root name="applicationContext">

			<helper id="mockDividerHelper" type="hex.ioc.parser.xml.mock.MockDividerHelper" map-type="hex.ioc.parser.xml.mock.IMockDividerHelper"/>

			<service id="myService" type="hex.ioc.parser.xml.mock.MockStubStatefulService"/>

			<module id="myModuleA" type="hex.ioc.parser.xml.mock.MockModuleWithServiceCallback">
				<listen ref="myService">
					<event static-ref="hex.ioc.parser.xml.mock.MockStubStatefulService.INT_VO_UPDATE"
						   method="onFloatServiceCallback"
						   strategy="hex.ioc.parser.xml.mock.MockIntDividerEventAdapterStrategy"
						   injectedInModule="true"/>
				</listen>
			</module>

			<module id="myModuleB" type="hex.ioc.parser.xml.mock.AnotherMockModuleWithServiceCallback">
				<listen ref="myService">
					<event static-ref="hex.ioc.parser.xml.mock.MockStubStatefulService.INT_VO_UPDATE"
						   method="onFloatServiceCallback"
						   strategy="hex.ioc.parser.xml.mock.MockIntDividerEventAdapterStrategy"
						   injectedInModule="false"/>
				</listen>
			</module>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );

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
		var source : String = '
		<root name="applicationContext">

			<constant id="constant" static-ref="hex.ioc.parser.xml.mock.MockStubStatefulService.INT_VO_UPDATE"/>

			<object id="object" type="Object">
				<property name="property" static-ref="hex.ioc.parser.xml.mock.MockStubStatefulService.INT_VO_UPDATE"/>
			</object>

			<instance id="instance" type="hex.ioc.parser.xml.mock.ClassWithConstantConstantArgument">
				<argument static-ref="hex.ioc.parser.xml.mock.MockStubStatefulService.INT_VO_UPDATE"/>
			</instance>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );

		var note : String = this._builderFactory.getCoreFactory().locate( "constant" );
		Assert.isNotNull( note, "" );
		Assert.equals( note, MockStubStatefulService.INT_VO_UPDATE, "" );

		var object : Dynamic = this._builderFactory.getCoreFactory().locate( "object" );
		Assert.isNotNull( object, "" );
		Assert.equals( object.property, MockStubStatefulService.INT_VO_UPDATE, "" );

		var instance : ClassWithConstantConstantArgument = this._builderFactory.getCoreFactory().locate( "instance" );
		Assert.isNotNull( instance, "" );
		Assert.equals( instance.constant, MockStubStatefulService.INT_VO_UPDATE, "" );
	}
	
	@Async( "test EventProxy" )
	public function testEventProxy() : Void
	{
		var source : String = '
		<root name="applicationContext">

			<chat id="chat" type="hex.ioc.parser.xml.mock.MockChatModule"/>

			<receiver id="receiver" type="hex.ioc.parser.xml.mock.MockReceiverModule"/>

			<parser id="parser" type="hex.ioc.parser.xml.mock.MockMessageParserModule" map-type="hex.ioc.parser.xml.mock.IMockMessageParserModule"/>

			<proxy id="eventProxy" type="hex.event.EventProxy">
				<argument ref="receiver"/>
				<argument ref="receiver.onMessage"/>
				<listen ref="chat">
					<event static-ref="hex.ioc.parser.xml.mock.MockChatModule.TEXT_INPUT" strategy="hex.ioc.parser.xml.mock.MockChatEventAdapterStrategyMacro"/>
				</listen>
			</proxy>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );
		
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
		var source : String = '
		<root name="applicationContext">

			<chat id="chat" type="hex.ioc.parser.xml.mock.MockChatModule"/>

			<receiver id="receiver" type="hex.ioc.parser.xml.mock.MockReceiverModule" map-type="hex.ioc.parser.xml.mock.MockReceiverModule"/>
			
			<parser id="parser" type="hex.ioc.parser.xml.mock.MockMessageParserModule" map-type="hex.ioc.parser.xml.mock.IMockMessageParserModule"/>

			<trigger id="eventTrigger" type="Object">
				<listen ref="chat">
					<event static-ref="hex.ioc.parser.xml.mock.MockChatModule.TEXT_INPUT" strategy="hex.ioc.parser.xml.mock.MockChatAdapterStrategyMacro"/>
				</listen>
			</trigger>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );
		
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
		var source : String = '
		<root name="applicationContext">
		
			<module id="myModule" type="hex.ioc.parser.xml.mock.MockMappedModule" map-type="hex.ioc.parser.xml.mock.IMockMappedModule"/>

		</root>';

		var xml : Xml = Xml.parse( source );
		this._build( xml );
		
		var myModule : MockMappedModule = this._builderFactory.getCoreFactory().locate( "myModule" );
		Assert.isNotNull( myModule, "" );
		Assert.isInstanceOf( myModule, MockMappedModule, "" );
		
		Assert.equals( myModule, this._applicationContext.getBasicInjector().getInstance( IMockMappedModule, "myModule" ), "" );
	}
	
	@Test( "test if attribute" )
	public function testIfAttribute() : Void
	{
		var source : String = '
		<root name="applicationContext">
		
			<msg id="message" value="hello debug" if="debug,release"/>
			<msg id="message" value="hello production" if="production"/>

		</root>';
		
		this._applicationAssembler.addConditionalProperty ( ["production" => true, "debug" => false, "release" => false] );
		var xml : Xml = Xml.parse( source );
		this._build( xml );
		
		Assert.equals( "hello production", this._builderFactory.getCoreFactory().locate( "message" ), "message value should equal 'hello production'" );
	}
	
	/*@Test( "test file preprocessor" )
	public function testFilePreprocessor() : Void
	{
		var source : String = '
		<root name="applicationContext">
		
			<msg id="message" value=${hello}/>

		</root>';
	}*/
}