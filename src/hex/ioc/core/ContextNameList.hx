package hex.ioc.core;

import hex.error.PrivateConstructorException;

/**
 * ...
 * @author Francis Bourre
 */
class ContextNameList
{
	static public inline var PROPERTY 							: String = "property";
	static public inline var ARGUMENT 							: String = "argument";
	static public inline var METHOD_CALL 						: String = "method-call";
	static public inline var LISTEN 							: String = "listen";
	static public inline var ITEM 								: String = "item";
	static public inline var KEY 								: String = "key";
	static public inline var VALUE 								: String = "value";
	static public inline var MAP_NAME 							: String = "map-name";
	static public inline var EVENT 								: String = "event";
	
	static public var ROOT 										: String = "root";

	private function new() 
	{
		throw new PrivateConstructorException( "'ContextNameList' class can't be instantiated." );
	}
}