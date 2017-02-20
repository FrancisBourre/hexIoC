package hex.ioc.parser.xml.mock;

import hex.control.async.AsyncCommand;
import hex.core.IAnnotationParsable;

/**
 * ...
 * @author Francis
 */
class MockAsyncCommandWithAnnotation extends AsyncCommand implements IAnnotationParsable
{
	public static var lastResult : String;
	
    @Value( "" )
	public var languageTest : String;

    public function new()
    {
        super();
    }

    override public function execute() : Void
    {
        MockAsyncCommandWithAnnotation.lastResult = this.languageTest;
    }
}