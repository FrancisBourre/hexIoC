package hex.ioc.vo;

/**
 * @author Francis Bourre
 */
typedef ConstructorVODef =
{
	var className           : String;
	var arguments       	: Array<Dynamic>;
	var staticCall       	: String;
	var factory         	: String;
	var staticRef			: String;
	var injectInto      	: Bool;
	var injectorCreation 	: Bool;
}