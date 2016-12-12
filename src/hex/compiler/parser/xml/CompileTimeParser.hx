package hex.compiler.parser.xml;

import haxe.macro.Context;
import hex.ioc.assembler.IApplicationAssembler;
import hex.ioc.parser.xml.XmlAssemblingExceptionReporter;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeParser 
{
	var _contextData 		: Dynamic;
	var _assembler 			: IApplicationAssembler;
	
	var _parserCollection 	: CompileTimeParserCollection;
	var _importHelper 		: ClassImportHelper;
	var _exceptionReporter 	: XmlAssemblingExceptionReporter;
	
	public function new( ?parserCollection : CompileTimeParserCollection )
	{
		if ( parserCollection != null )
		{
			this._parserCollection = parserCollection;
		}
		else
		{
			this._parserCollection = new CompileTimeParserCollection();
		}
	}
	
	public function setImportHelper( importHelper : ClassImportHelper ) : Void
	{
		this._importHelper = importHelper;
	}
	
	public function setExceptionReporter( exceptionReporter : XmlAssemblingExceptionReporter ) : Void
	{
		this._exceptionReporter = exceptionReporter;
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
			Context.error ( this + ".parse() can't retrieve instance of ApplicationAssembler", Context.currentPos() );
		}

		if ( context != null )
		{
			this.setContextData( context );

		} else
		{
			Context.error ( this + ".parse() can't retrieve IoC context data", Context.currentPos() );
		}

		if ( this._parserCollection == null )
		{
			this._parserCollection = new CompileTimeParserCollection();
		}

		while ( this._parserCollection.hasNext() )
		{
			var parser = this._parserCollection.next();
			parser.setImportHelper( this._importHelper );
			parser.setExceptionReporter( this._exceptionReporter );
			parser.setApplicationAssembler( this._assembler );
			parser.setContextData( this._contextData );
			parser.parse();

			this._contextData = parser.getContextData();
		}

		this._parserCollection.reset();
	}
}