package hex.ioc.parser.xml.mock;
import hex.module.IModule;

/**
 * @author Francis Bourre
 */
interface IMockMessageParserModule extends IModule
{
	function parse( message : String ) : String;
}