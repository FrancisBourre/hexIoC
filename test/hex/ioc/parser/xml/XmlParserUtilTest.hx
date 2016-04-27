package hex.ioc.parser.xml;

import hex.ioc.vo.ConstructorVO;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class XmlParserUtilTest
{
	@Test( "test getArguments with list of arguments" )
	public function testGetArgumentsWithListOfArguments() : Void
	{
		var xml : String = '<size id="rectSize" type="flash.geom.Point"><argument type="Int" value="30"/><argument type="Bool" value="true"/></size>';
		var argXML : Xml = Xml.parse( xml );
		var args : Array<ConstructorVO> = XMLParserUtil.getArguments( "ownerID", argXML.firstElement(), "" );

		Assert.equals( 2, args.length, "Arguments length should be 2" );
		Assert.equals( "Int", args[0].type, "Type should be 'Int'" );
		Assert.equals( "30", args[0].arguments[ 0 ], "Value should be '30'" );
		Assert.equals( "Bool", args[1].type, "Type should be 'Bool'" );
		Assert.equals( "true", args[1].arguments[ 0 ], "Value should be 'true'" );
	}
	
	@Test( "test getArguments with single argument" )
	public function testGetArgumentsWithSingleArgument() : Void
	{
		var xml : String = '<class id="userInfoServiceNoteClass" type="Class" value="service.userinfo.note.UserInfoServiceNote"/>';
		var argXML : Xml = Xml.parse( xml );
		var args : Array<ConstructorVO> = XMLParserUtil.getArguments( "ownerID", argXML.firstElement(), "" );
		
		Assert.equals( 1, args.length, "Arguments length should be 1" );
		Assert.equals( "String", args[0].type, "Type should be 'Class'" );
		Assert.equals( "service.userinfo.note.UserInfoServiceNote", args[0].arguments[ 0 ], "Value should be 'service.userinfo.note.UserInfoServiceNote'" );
	}
	
	@Test( "test getEventArguments" )
	public function testGetEventArguments() : Void
	{
		var xml : String = '<listen ref="bottomIconListModule"><event static-ref="constant.iconlist.CIconNote.SET_SIZE_ICON" method="setSizeIconButton"/><event name="onAddLine" strategy="eventstrategy.chat.AddLineEventStrategy" method="addNewLine" injectedInModule="true"/></listen>';
		var argXML : Xml = Xml.parse( xml );
		var args : Array<Dynamic> = XMLParserUtil.getEventArguments( argXML.firstElement() );
		
		Assert.equals( 2, args.length, "Arguments length should be 2" );
		Assert.isFalse( args[0].injectedInModule, "'injectedInModule' should be false" );
		Assert.isNull( args[0].name, "'name' should be null" );
		Assert.equals( "constant.iconlist.CIconNote.SET_SIZE_ICON", args[0].staticRef, "'staticRef' should be 'constant.iconlist.CIconNote.SET_SIZE_ICON'" );
		Assert.equals( "setSizeIconButton", args[0].method, "'method' should be 'setSizeIconButton'" );
		Assert.isNull( args[0].strategy, "'strategy' should be null" );
		
		Assert.isTrue( args[1].injectedInModule, "'injectedInModule' should be true" );
		Assert.equals( "onAddLine", args[1].name, "'name' should be 'onAddLine'" );
		Assert.isNull( args[1].staticRef, "'staticRef' should be null" );
		Assert.equals( "addNewLine", args[1].method, "'method' should be 'addNewLine'" );
		Assert.equals( "eventstrategy.chat.AddLineEventStrategy", args[1].strategy, "'strategy' should be 'eventstrategy.chat.AddLineEventStrateg'" );
	}
}