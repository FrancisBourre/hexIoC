package hex.ioc.parser;

/**
 * @author Francis Bourre
 */
interface IParserCollection<T:IContextParser<ContentType>, ContentType>
{
	function next() : T;
	
	function hasNext() : Bool;
		
	function reset() : Void;
}