package hex.ioc.parser;

import hex.ioc.assembler.ApplicationContext;
import hex.ioc.assembler.IApplicationAssembler;

/**
 * @author Francis Bourre
 */
interface IParserCommand 
{
	function parse( ) : Void;

	function setContextData( data : Dynamic ) : Void;
	
	function getContextData() : Dynamic;
	
	function getApplicationContext( applicationContextClass : Class<ApplicationContext> = null ) : ApplicationContext;

	function getApplicationAssembler() : IApplicationAssembler;
	
	function setApplicationAssembler( applicationAssembler : IApplicationAssembler ) : Void;
}