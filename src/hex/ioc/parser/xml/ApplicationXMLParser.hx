package hex.ioc.parser.xml;

import hex.error.NullPointerException;
import hex.ioc.assembler.IApplicationAssembler;

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
			throw new NullPointerException ( this + ".parse() can't retrieve instance of ApplicationAssembler" );
		}

		if ( context != null )
		{
			this.setContextData( context );

		} else
		{
			throw new NullPointerException ( this + ".parse() can't retrieve IoC context data" );
		}

		if ( this._parserCollection == null )
		{
			this._parserCollection = new XMLParserCollection();
		}

		while ( this._parserCollection.hasNext() )
		{
			var parser = this._parserCollection.next();
			parser.setContextData( this._contextData );
			parser.setApplicationAssembler( this._assembler );
			parser.parse();

			this._contextData = parser.getContextData();
		}

		this._parserCollection.reset();
	}
}