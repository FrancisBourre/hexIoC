package hex.ioc.parser;

/**
 * @author Francis Bourre
 */
interface IParserCollection<T:IParserCommand>
{
	function next() : T;
	
	function hasNext() : Bool;
		
	function reset() : Void;
}