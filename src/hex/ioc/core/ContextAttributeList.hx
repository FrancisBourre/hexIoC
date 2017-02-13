package hex.ioc.core;

import hex.error.PrivateConstructorException;

/**
 * ...
 * @author Francis Bourre
 */
class ContextAttributeList
{
	static public inline var ID 					: String = hex.compiletime.xml.ContextAttributeList.ID;
	static public inline var TYPE 					: String = hex.compiletime.xml.ContextAttributeList.TYPE;
	static public inline var NAME 					: String = hex.compiletime.xml.ContextAttributeList.NAME;
	static public inline var REF 					: String = hex.compiletime.xml.ContextAttributeList.REF;
	static public inline var VALUE 					: String = hex.compiletime.xml.ContextAttributeList.VALUE;
	static public inline var FACTORY_METHOD 		: String = hex.compiletime.xml.ContextAttributeList.FACTORY_METHOD;
	public static inline var STATIC_REF 			: String = hex.compiletime.xml.ContextAttributeList.STATIC_REF;
	static public inline var STATIC_CALL 			: String = hex.compiletime.xml.ContextAttributeList.STATIC_CALL;
	static public inline var INJECTOR_CREATION 		: String = hex.compiletime.xml.ContextAttributeList.INJECTOR_CREATION;
	static public inline var INJECT_INTO 			: String = hex.compiletime.xml.ContextAttributeList.INJECT_INTO;
	static public inline var METHOD 				: String = hex.compiletime.xml.ContextAttributeList.METHOD;
	static public inline var PARSER_CLASS 			: String = hex.compiletime.xml.ContextAttributeList.PARSER_CLASS;
	public static inline var MAP_TYPE 				: String = hex.compiletime.xml.ContextAttributeList.MAP_TYPE;
	public static inline var MAP_NAME 				: String = hex.compiletime.xml.ContextAttributeList.MAP_NAME;
	public static inline var AS_SINGLETON 			: String = hex.compiletime.xml.ContextAttributeList.AS_SINGLETON;
	public static inline var IF 					: String = hex.compiletime.xml.ContextAttributeList.IF;
	public static inline var IF_NOT 				: String = hex.compiletime.xml.ContextAttributeList.IF_NOT;
	public static inline var FILE 					: String = hex.compiletime.xml.ContextAttributeList.FILE;
	
	static public inline var LOCATOR 				: String = "locator";
	public static inline var STRATEGY 				: String = "strategy";
	public static inline var INJECTED_IN_MODULE 	: String = "injectedInModule";
	public static inline var COMMAND_CLASS 			: String = "command-class";
	public static inline var FIRE_ONCE 				: String = "fire-once";
	public static inline var CONTEXT_OWNER 			: String = "context-owner";
	public static inline var MESSAGE 				: String = "message";
	public static inline var STATE 					: String = "state";
	
	/** @private */
	function new() 
	{
		throw new PrivateConstructorException();
	}
}