package hex.ioc.parser.xml;

import hex.collection.HashMap;
import hex.control.payload.ExecutionPayload;
import hex.control.payload.PayloadEvent;
import hex.domain.ApplicationDomainDispatcher;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.assembler.IApplicationAssembler;
import hex.ioc.assembler.MockApplicationContextFactory;
import hex.ioc.parser.xml.mock.MockChatModule;
import hex.ioc.parser.xml.mock.MockFruitVO;
import hex.ioc.parser.xml.mock.MockMessageParserModule;
import hex.ioc.parser.xml.mock.MockReceiverModule;
import hex.ioc.parser.xml.mock.MockRectangle;
import hex.ioc.parser.xml.mock.MockSenderModule;
import hex.ioc.parser.xml.mock.MockServiceProvider;
import hex.ioc.parser.xml.mock.MockTranslationModule;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.PropertyVO;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.core.BuilderFactory;
import hex.structures.Point;
import hex.structures.Size;
import hex.unittest.assertion.Assert;

import hex.ioc.parser.xml.mock.MockRectangleFactory;
import hex.ioc.parser.xml.mock.MockPointFactory;
import hex.ioc.parser.xml.mock.MockXMLParser;
import hex.ioc.parser.xml.mock.MockChatAdapterStrategy;
import hex.ioc.parser.xml.mock.MockChatEventAdapterStrategyWithInjection;

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
		var source : String = '
		<root>
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
	
	@test( "test building simple instance with arguments" )
	public function testBuildingSimpleInstanceWithArguments() : Void
	{
		var source : String = '
		<root>
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
	
	@test( "test building multiple instances with references" )
	public function testBuildingMultipleInstancesWithReferences() : Void
	{
		var source : String = '
		<root>
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
	
	@test( "test building multiple instances with method calls" )
	public function testBuildingMultipleInstancesWithMethodCall() : Void
	{
		var source : String = '
		<root>
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
	
	@test( "test building singleton instance" )
	public function testBuildingSingletonInstance() : Void
	{
		var source : String = '
		<root>
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
	
	@test( "test factory with static method" )
	public function testFactoryWithStaticMethod() : Void
	{
		var source : String = '
		<root>
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
	
	@test( "test factory with singleton" )
	public function testFactoryWithSingleton() : Void
	{
		var source : String = '
		
		<root>
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
	
	@test( "test building XML with parser class" )
	public function testBuildingXMLWithParserClass() : Void
	{
		var source : String = '
		<root>

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
	
	@test( "test Array ref" )
	public function testArrayRef() : Void
	{
		var source : String = '
		<root>

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
	
	@test( "test Map ref" )
	public function testMapRef() : Void
	{
		var source : String = '
		<root>

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
	
	@test( "test domain listening" )
	public function testDomainListening() : Void
	{
		var source : String = '
		<root>

			<chat id="chat" type="hex.ioc.parser.xml.mock.MockChatModule">
				<listen ref="translation"/>
			</chat>

			<translation id="translation" type="hex.ioc.parser.xml.mock.MockTranslationModule">
				<listen ref="chat">
					<event name="onTextInput" method="onSomethingToTranslate"/>
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

		chat.dispatchDomainEvent( new PayloadEvent( "onTextInput", chat, [ new ExecutionPayload( "Bonjour", String ) ] ) );
		Assert.equals( "Hello", chat.translatedMessage, "" );
	}
	
	@test( "test domain listening with classAdapter" )
	public function testDomainListeningWithEventAdapter() : Void
	{
		var source : String = '
		<root>

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

		chat.dispatchDomainEvent( new PayloadEvent( MockChatModule.TEXT_INPUT, chat, [ new ExecutionPayload( "Bonjour", String ) ] ) );
		Assert.equals( "Hello", chat.translatedMessage, "" );
		Assert.isInstanceOf( chat.date, Date, "" );
	}
	
	@test( "test domain listening with classAdapter and injection" )
	public function testDomainListeningWithClassAdapterAndInjection() : Void
	{
		var source : String = '
		<root>

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

		chat.dispatchDomainEvent( new PayloadEvent( MockChatModule.TEXT_INPUT, chat, [ new ExecutionPayload( "Bonjour", String ) ] ) );
		Assert.equals( "BONJOUR", receiver.message, "" );
	}
	
	@test( "test domain dispatch after module initialisation" )
	public function testDomainDispatchAfterModuleInitialisation() : Void
	{
		var source : String = '
		<root>

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
}