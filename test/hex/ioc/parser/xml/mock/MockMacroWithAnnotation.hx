package hex.ioc.parser.xml.mock;

import hex.control.macro.Macro;
import hex.core.IAnnotationParsable;

/**
 * ...
 * @author Francis
 */
class MockMacroWithAnnotation extends Macro implements IAnnotationParsable
{
	public static var lastResult : String;
	
    @Value( "" )
	public var languageTest : String;

    override function _prepare() : Void
    {
        this.add( MockCommandWithAnnotation );
		MockMacroWithAnnotation.lastResult = this.languageTest;
    }
}