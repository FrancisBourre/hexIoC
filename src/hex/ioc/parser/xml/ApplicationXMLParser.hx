package hex.ioc.parser.xml;

import hex.error.NullPointerException;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.assembler.IApplicationAssembler;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationXMLParser
{
	var _contextData 		: Dynamic;
	var _assembler 			: IApplicationAssembler;
	var _parserCollection 	: IParserCollection;
	
	public function new( ?parserCollection : XMLParserCollection )
	{
		if ( parserCollection != null )
		{
			this._parserCollection = parserCollection;
		}
		else
		{
			this._parserCollection = new XMLParserCollection();
		}
	}

	public function setApplicationAssembler( applicationAssembler : IApplicationAssembler ) : Void
	{
		this._assembler = applicationAssembler;
	}

	public function getApplicationAssembler() : IApplicationAssembler
	{
		return this._contextData;
	}

	public function setContextData( context : Dynamic ) : Void
	{
		this._contextData = context;
	}

	public function getContextData() : Dynamic
	{
		return this._contextData;
	}

	public function parse( applicationAssembler : IApplicationAssembler, context : Dynamic ) : Void
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
			var parser : IParserCommand = this._parserCollection.next();
			parser.setContextData( this._contextData );
			parser.setApplicationAssembler( this._assembler );
			parser.parse();

			this._contextData = parser.getContextData();
		}

		this._parserCollection.reset();
	}
}