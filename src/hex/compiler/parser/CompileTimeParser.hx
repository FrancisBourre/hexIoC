package hex.compiler.parser;

import haxe.macro.Context;
import hex.compiler.core.CompileTimeContextFactory;
import hex.compiletime.DSLParser;
import hex.compiletime.util.ClassImportHelper;
import hex.core.IApplicationAssembler;
import hex.compiletime.error.IExceptionReporter;
import hex.ioc.assembler.CompileTimeApplicationContext;
import hex.parser.AbstractParserCollection;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeParser<ContentType, ParserType:DSLParser<ContentType>, RequestType> 
{
	var _contextData 		: ContentType;
	var _assembler 			: IApplicationAssembler;
	var _importHelper 		: ClassImportHelper;
	var _parserCollection 	: AbstractParserCollection<ParserType, ContentType>;
	var _exceptionReporter 	: IExceptionReporter<ContentType>;
	
	public function new( parserCollection : AbstractParserCollection<ParserType, ContentType> )
	{
		this._parserCollection = parserCollection;
	}
	
	public function setImportHelper( importHelper : ClassImportHelper ) : Void
	{
		this._importHelper = importHelper;
	}
	
	public function setExceptionReporter( exceptionReporter : IExceptionReporter<ContentType> ) : Void
	{
		this._exceptionReporter = exceptionReporter;
	}

	public function setApplicationAssembler( applicationAssembler : IApplicationAssembler ) : Void
	{
		this._assembler = applicationAssembler;
	}

	public function getApplicationAssembler() : IApplicationAssembler
	{
		return this._assembler;
	}

	public function setContextData( contextData : ContentType ) : Void
	{
		this._contextData = contextData;
	}

	public function getContextData() : ContentType
	{
		return this._contextData;
	}

	public function parse( applicationAssembler : IApplicationAssembler, contextData : ContentType ) : Void
	{
		if ( applicationAssembler != null )
		{
			this.setApplicationAssembler( applicationAssembler );

		} else
		{
			Context.error ( "Application assembler is null", Context.currentPos() );
		}

		if ( contextData != null )
		{
			this.setContextData( contextData );

		} else
		{
			Context.error ( "Context data is null", Context.currentPos() );
		}

		if ( this._parserCollection == null )
		{
			Context.error ( "Parsers collection is null", Context.currentPos() );
		}

		while ( this._parserCollection.hasNext() )
		{
			//Get current parser
			var parser = this._parserCollection.next();
			
			//Initialize settings
			parser.setFactoryClass( CompileTimeContextFactory );
			parser.setApplicationContextDefaultClass( CompileTimeApplicationContext );
			parser.setImportHelper( this._importHelper );
			parser.setExceptionReporter( this._exceptionReporter );
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