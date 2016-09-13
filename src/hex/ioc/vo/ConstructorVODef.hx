package hex.ioc.vo;

/**
 * @author Francis Bourre
 */
typedef ConstructorVODef =
{
	var type            	: String;
	var arguments       	: Array<Dynamic>;
	var factory         	: String;
	var singleton       	: String;
	var staticRef			: String;
	var injectInto      	: Bool;
	var injectorCreation 	: Bool;
}