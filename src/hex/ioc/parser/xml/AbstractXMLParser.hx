package hex.ioc.parser.xml;

import hex.core.IBuilder;
import hex.error.IllegalArgumentException;
import hex.error.NullPointerException;
import hex.factory.BuildRequest;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.error.ParsingException;
import hex.ioc.parser.AbstractContextParser;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractXMLParser extends AbstractContextParser<Xml>
{
	var _builder 						: IBuilder<BuildRequest>;
	var _applicationContextName 		: String;
	var _applicationContextClassName 	: String;
	var _applicationContextClass 		: Class<AbstractApplicationContext>;
	
	function new()
	{
		super();
	}
	
	@final
	override public function getApplicationContext() : AbstractApplicationContext
	{
		return this._applicationAssembler.getApplicationContext( this._applicationContextName, this._applicationContextClass );
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
				
				var context = this._applicationAssembler.getApplicationContext( this._applicationContextName );
				this._builder = this._applicationAssembler.getBuilder( context );
			}
			else
			{
				throw new IllegalArgumentException( this + ".setContext() failed. Data should be an instance of Xml." );
			}
		}
		else
		{
			throw new NullPointerException( this + ".setContext() failed. Data was null." );
		}
	}
	
	function _findApplicationContextName( xml : Xml ) : Void
	{
		this._applicationContextName = xml.firstElement().get( "name" );
		if ( this._applicationContextName == null )
		{
			throw new ParsingException( this + " failed to retrieve applicationContext name. You should add 'name' attribute to the root of your xml context" );
		}
	}
	
	function _findApplicationContextClassName( xml : Xml ) : Void
	{
		//Build applicationContext class for the 1st time
		this._applicationContextClassName = this.getContextData().firstElement().get( "type" );

		if ( this._applicationContextClassName != null )
		{
			try
			{
				this._applicationContextClass = cast Type.resolveClass( this._applicationContextClassName );
				this._applicationAssembler.getApplicationContext( this._applicationContextName, this._applicationContextClass );
			}
			catch ( error : Dynamic )
			{
				throw new ParsingException( this + " failed to instantiate applicationContext class named '" + this._applicationContextClassName + "'" );
			}
		}
	}
}