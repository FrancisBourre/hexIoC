package hex.compiler.core;

#if macro
import hex.core.ContextTypeList;

/**
 * These are the factory settings for the CompileTimeContextFactory
 * @author Francis Bourre
 */
class CompileTimeSettings 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public var factoryMap = 
	[
		ContextTypeList.ARRAY					=> hex.compiletime.factory.ArrayFactory.build,
		ContextTypeList.BOOLEAN					=> hex.compiletime.factory.BoolFactory.build,
		ContextTypeList.INT						=> hex.compiletime.factory.IntFactory.build,
		ContextTypeList.NULL					=> hex.compiletime.factory.NullFactory.build,
		ContextTypeList.FLOAT					=> hex.compiletime.factory.FloatFactory.build,
		ContextTypeList.OBJECT					=> hex.compiletime.factory.DynamicObjectFactory.build,
		ContextTypeList.STRING					=> hex.compiletime.factory.StringFactory.build,
		ContextTypeList.UINT					=> hex.compiletime.factory.UIntFactory.build,
		ContextTypeList.DEFAULT					=> hex.compiletime.factory.StringFactory.build,
		ContextTypeList.HASHMAP					=> hex.compiletime.factory.HashMapFactory.build,
		ContextTypeList.CLASS					=> hex.compiletime.factory.ClassFactory.build,
		ContextTypeList.XML						=> hex.compiletime.factory.XmlFactory.build,
		ContextTypeList.FUNCTION				=> hex.compiletime.factory.FunctionFactory.build,
		ContextTypeList.STATIC_VARIABLE			=> hex.compiletime.factory.StaticVariableFactory.build,
		ContextTypeList.MAPPING_CONFIG			=> hex.compiletime.factory.MappingConfigurationFactory.build,
		ContextTypeList.MAPPING_DEFINITION		=> hex.compiletime.factory.MappingDefinitionFactory.build,
		ContextTypeList.ALIAS					=> hex.compiletime.factory.AliasFactory.build,
		ContextTypeList.CONTEXT					=> hex.compiletime.factory.ContextFactory.build,
		ContextTypeList.CONTEXT_ARGUMENT		=> hex.compiletime.factory.ContextArgumentFactory.build,
		ContextTypeList.CLOSURE					=> hex.compiletime.factory.ClosureFactory.build
	];
}
#end
