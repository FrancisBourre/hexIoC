package hex.ioc.parser;

import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.IApplicationAssembler;

/**
 * @author Francis Bourre
 */
interface IContextParser<ContentType> 
{
	function parse() : Void;

	function setContextData( data : ContentType ) : Void;
	
	function getContextData() : ContentType;
	
	function getApplicationContext() : AbstractApplicationContext;

	function getApplicationAssembler() : IApplicationAssembler;
	
	function setApplicationAssembler( applicationAssembler : IApplicationAssembler ) : Void;
}