package hex.ioc.parser;

import hex.core.IApplicationContext;
import hex.core.IApplicationAssembler;

/**
 * @author Francis Bourre
 */
interface IContextParser<ContentType> 
{
	function parse() : Void;

	function setContextData( data : ContentType ) : Void;
	
	function getContextData() : ContentType;
	
	function getApplicationContext() : IApplicationContext;

	function getApplicationAssembler() : IApplicationAssembler;
	
	function setApplicationAssembler( applicationAssembler : IApplicationAssembler ) : Void;
}