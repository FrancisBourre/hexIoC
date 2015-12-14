package hex.ioc.parser;

/**
 * @author Francis Bourre
 */
interface IParserCollection 
{
	function next() : IParserCommand;
	
	function hasNext() : Bool;
		
	function reset() : Void;
}