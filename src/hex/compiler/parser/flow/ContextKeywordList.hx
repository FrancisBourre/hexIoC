package hex.compiler.parser.flow;

import hex.error.PrivateConstructorException;

/**
 * ...
 * @author Francis Bourre
 */
@:final 
class ContextKeywordList 
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }
	
	static public inline var CONTEXT 				: String = "context";
	static public inline var TYPE 					: String = "type";
	static public inline var NAME 					: String = "name";
}