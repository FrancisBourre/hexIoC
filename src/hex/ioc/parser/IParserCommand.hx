package hex.ioc.parser;

import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.assembler.ApplicationContext;

/**
 * @author Francis Bourre
 */

interface IParserCommand 
{
	function parse( ) : Void;

	function setContextData( data : Dynamic, applicationContext : ApplicationContext ) : Void;
	
	function getContextData() : Dynamic;

	function getApplicationAssembler() : ApplicationAssembler;
	
	function setApplicationAssembler( applicationAssembler : ApplicationAssembler ) : Void;
}