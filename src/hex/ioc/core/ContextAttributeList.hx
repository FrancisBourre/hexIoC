package hex.ioc.core;

import hex.error.PrivateConstructorException;

/**
 * ...
 * @author Francis Bourre
 */
class ContextAttributeList
{
	static public inline var ID 					: String = "id";
	static public inline var TYPE 					: String = hex.compiletime.xml.ContextAttributeList.TYPE;
	static public inline var NAME 					: String = hex.compiletime.xml.ContextAttributeList.NAME;
	static public inline var REF 					: String = "ref";
	static public inline var VALUE 					: String = "value";
	static public inline var FACTORY_METHOD 		: String = "factory-method";
	static public inline var STATIC_CALL 			: String = "static-call";
	static public inline var INJECTOR_CREATION 		: String = "injector-creation";
	static public inline var INJECT_INTO 			: String = "inject-into";
	static public inline var METHOD 				: String = "method";
	static public inline var PARSER_CLASS 			: String = "parser-class";
	static public inline var LOCATOR 				: String = "locator";
	public static inline var MAP_TYPE 				: String = "map-type";
	public static inline var MAP_NAME 				: String = "map-name";
	public static inline var AS_SINGLETON 			: String = "as-singleton";
	public static inline var STRATEGY 				: String = "strategy";
	public static inline var INJECTED_IN_MODULE 	: String = "injectedInModule";
	public static inline var STATIC_REF 			: String = "static-ref";
	public static inline var COMMAND_CLASS 			: String = "command-class";
	public static inline var FIRE_ONCE 				: String = "fire-once";
	public static inline var CONTEXT_OWNER 			: String = "context-owner";
	public static inline var IF 					: String = hex.compiletime.xml.ContextAttributeList.IF;
	public static inline var IF_NOT 				: String = hex.compiletime.xml.ContextAttributeList.IF_NOT;
	public static inline var FILE 					: String = "file";
	public static inline var MESSAGE 				: String = "message";
	public static inline var STATE 					: String = "state";
	
	function new() 
	{
		throw new PrivateConstructorException( "'ContextAttributeList' class can't be instantiated." );
	}
}