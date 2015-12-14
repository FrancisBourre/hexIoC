package hex.ioc.parser.xml;
import hex.error.NullPointerException;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.assembler.ApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class XMLContextParser
{
	private var _contextData 		: Dynamic;
	private var _assembler 			: ApplicationAssembler;
	private var _parserCollection 	: IParserCollection;

	public function setApplicationAssembler( applicationAssembler : ApplicationAssembler ) : void
	{
		this._assembler = applicationAssembler;
	}

	public function getApplicationAssembler() : ApplicationAssembler
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

	public function parse( applicationContext : ApplicationContext, applicationAssembler : ApplicationAssembler, context : Dynamic, ?autoBuild : Bool = false ) : void
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
			throw new Error ( this + ".parse() can't retrieve IoC context data" );
		}

		if ( this._parserCollection == null )
		{
			this._parserCollection = new XMLParserCollection();
		}

		while ( this._parserCollection.hasNext() )
		{
			var parser : IParserCommand = this._parserCollection.next();
			parser.setContextData( this._contextData, applicationContext );
			parser.setApplicationAssembler( this._assembler );
			parser.parse();

			this._contextData = parser.getContextData();
		}

		this._parserCollection.reset();

		if ( autoBuild )
		{
			this._assembler.buildEverything();
		}
	}

	public function setParserCollection( collection : IParserCollection  ) : Void
	{
		this._parserCollection = collection;
	}
	
}