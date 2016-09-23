package hex.ioc.parser.xml.mock;

import hex.control.Request;
import hex.control.command.BasicCommand;
import hex.core.IAnnotationParsable;

/**
 * ...
 * @author Francis
 */
class MockCommandWithAnnotation extends BasicCommand implements IAnnotationParsable
{
	public static var lastResult : String;
	
    @Value( "" )
	public var languageTest : String;

    public function new()
    {
        super();
    }

    public function execute(?request : Request ) : Void
    {
        MockCommandWithAnnotation.lastResult = this.languageTest;
    }
}