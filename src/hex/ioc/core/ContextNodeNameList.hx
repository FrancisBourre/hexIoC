package hex.ioc.core;

import hex.error.PrivateConstructorException;

/**
 * ...
 * @author Francis Bourre
 */
class ContextNodeNameList
{
	static public inline var PROPERTY 		= hex.compiletime.xml.ContextNodeNameList.PROPERTY;
	static public inline var ARGUMENT 		= hex.compiletime.xml.ContextNodeNameList.ARGUMENT;
	static public inline var METHOD_CALL 	= hex.compiletime.xml.ContextNodeNameList.METHOD_CALL;
	static public inline var LISTEN 		= "listen";
	static public inline var ITEM 			= hex.compiletime.xml.ContextNodeNameList.ITEM;
	static public inline var KEY 			= hex.compiletime.xml.ContextNodeNameList.KEY;
	static public inline var VALUE 			= hex.compiletime.xml.ContextNodeNameList.VALUE;
	static public inline var MAP_NAME 		= "map-name";
	static public inline var EVENT 			= "event";
	static public inline var ENTER 			= "enter";
	static public inline var EXIT 			= "exit";
	static public inline var TRANSITION 	= "transition";
	static public inline var MESSAGE 		= "message";
	static public inline var STATE 			= "state";
	
	static public var ROOT 					= "root";

	/** @private */
	function new() 
	{
		throw new PrivateConstructorException();
	}
}