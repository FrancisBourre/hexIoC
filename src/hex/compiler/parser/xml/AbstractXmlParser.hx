package hex.compiler.parser.xml;

#if macro
import hex.compiler.core.CompileTimeContextFactory;
import hex.compiletime.xml.ExceptionReporter;
import hex.compiletime.xml.ContextAttributeList;
import hex.compiletime.DSLParser;
import hex.compiletime.xml.IXmlPositionTracker;
import hex.core.IApplicationContext;
import hex.core.IBuilder;
import hex.factory.BuildRequest;
import hex.ioc.assembler.CompileTimeApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractXmlParser extends DSLParser<Xml>
{
	var _builder 						: IBuilder<BuildRequest>;
	var _applicationContextName 		: String;
	var _applicationContextClass 		: {name: String, pos: haxe.macro.Expr.Position};
	var _positionTracker				: IXmlPositionTracker;
	
	function new() 
	{
		super();
	}
	
	@final
	override public function getApplicationContext() : IApplicationContext
	{
		return this._applicationAssembler.getApplicationContext( this._applicationContextName, CompileTimeApplicationContext );
	}
	
	@final
	override public function setContextData( data : Xml ) : Void
	{
		this._positionTracker = cast ( this._exceptionReporter, ExceptionReporter ).positionTracker;
		
		if ( data != null )
		{
			if ( Std.is( data, Xml ) )
			{
				this._contextData = data;
				this._findApplicationContextName( data );
				this._findApplicationContextClass( data );
				
				this._builder = this._applicationAssembler.getFactory( CompileTimeContextFactory, this._applicationContextName, CompileTimeApplicationContext );
			}
			else
			{
				this._exceptionReporter.report( "Context data should be an instance of Xml." );
			}
		}
		else
		{
			this._exceptionReporter.report( "Context data is null." );
		}
	}
	
	function _findApplicationContextName( xml : Xml ) : Void
	{
		this._applicationContextName = xml.firstElement().get( ContextAttributeList.NAME );
		
		if ( this._applicationContextName == null )
		{
			this._exceptionReporter.report( "Fails to retrieve applicationContext name. You should add 'name' attribute to the root of your xml context", 
				this._positionTracker.getPosition( xml  ) );
		}
	}
	
	function _findApplicationContextClass( xml : Xml ) : Void
	{
		var name = xml.firstElement().get( ContextAttributeList.TYPE );
		var pos = name != null ? this._positionTracker.getPosition( xml.firstElement() ) : null;
		this._applicationContextClass = { name: name, pos: pos };
	}
	
	function _throwMissingTypeException( type : String, xml : Xml, attributeName : String ) : Void 
	{
		this._exceptionReporter.report( "Type not found '" + type + "' ", this._positionTracker.getPosition( xml, attributeName ) );
	}
}
#end