package hex.compiler.parser.xml;

import haxe.macro.Context;
import hex.compiler.core.CompileTimeContextFactory;
import hex.core.IApplicationContext;
import hex.core.IBuilder;
import hex.factory.BuildRequest;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.CompileTimeApplicationContext;
import hex.ioc.core.ContextAttributeList;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractXmlParser extends DSLParser<Xml>
{
	var _builder 						: IBuilder<BuildRequest>;
	var _applicationContextName 		: String;
	var _applicationContextClassName 	: String;
	
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
		if ( data != null )
		{
			if ( Std.is( data, Xml ) )
			{
				this._contextData = data;
				this._findApplicationContextName( data );
				this._findApplicationContextClassName( data );
				
				this._builder = this._applicationAssembler.getFactory( CompileTimeContextFactory, this._applicationContextName, CompileTimeApplicationContext );
			}
			else
			{
				Context.error( "Context data should be an instance of Xml.", Context.currentPos() );
			}
		}
		else
		{
			Context.error( "Context data is null.", Context.currentPos() );
		}
	}
	
	function _findApplicationContextName( xml : Xml ) : Void
	{
		this._applicationContextName = xml.firstElement().get( ContextAttributeList.NAME );
		
		if ( this._applicationContextName == null )
		{
			Context.error( "Fails to retrieve applicationContext name. You should add 'name' attribute to the root of your xml context", 
			this._exceptionReporter.getPosition( xml  ) );
		}
	}
	
	function _findApplicationContextClassName( xml : Xml ) : Void
	{
		this._applicationContextClassName = xml.firstElement().get( ContextAttributeList.TYPE );
	}
	
	function _throwMissingTypeException( type : String, xml : Xml, attributeName : String ) : Void 
	{
		Context.error( "Type not found '" + type + "' ", this._exceptionReporter.getPosition( xml, attributeName ) );
	}
	
	function _throwMissingApplicationContextClassException() : Void
	{
		this._throwMissingTypeException( this._applicationContextClassName, this.getContextData(), ContextAttributeList.TYPE );
	}
}