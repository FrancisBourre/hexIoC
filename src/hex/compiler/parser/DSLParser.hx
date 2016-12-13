package hex.compiler.parser;

import hex.compiler.parser.xml.ClassImportHelper;
import hex.ioc.error.IAssemblingExceptionReporter;
import hex.ioc.parser.AbstractParserCommand;

/**
 * ...
 * @author Francis Bourre
 */
class DSLParser<ContentType> extends AbstractParserCommand<ContentType>
{
	var _importHelper 		: ClassImportHelper;
	var _exceptionReporter 	: IAssemblingExceptionReporter<ContentType>;
	
	public function new() 
	{
		super();
	}
	
	@final
	public function setImportHelper( importHelper : ClassImportHelper ) : Void
	{
		this._importHelper = importHelper;
	}
	
	@final
	public function setExceptionReporter( exceptionReporter : IAssemblingExceptionReporter<ContentType> ) : Void
	{
		this._exceptionReporter = exceptionReporter;
	}
}