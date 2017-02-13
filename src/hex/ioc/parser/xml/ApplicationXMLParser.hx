package hex.ioc.parser.xml;

import hex.core.IApplicationAssembler;
import hex.error.NullPointerException;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.core.ContextFactory;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationXMLParser
{
	var _contextData 		: Xml;
	var _assembler 			: IApplicationAssembler;
	var _parserCollection 	: XMLParserCollection;
	
	public function new( ?parserCollection : XMLParserCollection )
	{
		if ( parserCollection != null )
		{
			this._parserCollection = parserCollection;
		}
		else
		{
			this._parserCollection = new XMLParserCollection( true );
		}
	}
	
	inline static public function parseString( assembler : IApplicationAssembler, s : String ) : Void
	{
		ApplicationXMLParser.parseXml( assembler, Xml.parse( s ) );
	}
	
	inline static public function parseXml( assembler : IApplicationAssembler, xml : Xml ) : Void
	{
		var applicationXMLParser = new ApplicationXMLParser();
		applicationXMLParser.parse( assembler, xml );
	}

	public function setApplicationAssembler( applicationAssembler : IApplicationAssembler ) : Void
	{
		this._assembler = applicationAssembler;
	}

	public function getApplicationAssembler() : IApplicationAssembler
	{
		return this._assembler;
	}

	public function setContextData( context : Xml ) : Void
	{
		this._contextData = context;
	}

	public function getContextData() : Xml
	{
		return this._contextData;
	}

	public function parse( applicationAssembler : IApplicationAssembler, context : Xml ) : Void
	{
		if ( applicationAssembler != null )
		{
			this.setApplicationAssembler( applicationAssembler );

		} else
		{
			throw new NullPointerException ( "ApplicationAssembler is null." );
		}

		if ( context != null )
		{
			this.setContextData( context );

		} else
		{
			throw new NullPointerException ( "Context data is null." );
		}

		if ( this._parserCollection == null )
		{
			//Set default parser collection
			this._parserCollection = new XMLParserCollection();
		}

		while ( this._parserCollection.hasNext() )
		{
			//Get current parser
			var parser = this._parserCollection.next();
			
			//Initialize settings
			parser.setFactoryClass( ContextFactory );
			parser.setApplicationContextDefaultClass( ApplicationContext );
			parser.setApplicationAssembler( this._assembler );
			
			//Do parsing
			parser.setContextData( this._contextData );
			parser.parse();

			//Get back parsed data
			this._contextData = parser.getContextData();
		}

		this._parserCollection.reset();
	}
}