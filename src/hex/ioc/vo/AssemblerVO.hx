package hex.ioc.vo;

import hex.ioc.error.IAssemblingExceptionReporter;

/**
 * ...
 * @author Francis Bourre
 */
class AssemblerVO
{
	public function new() 
	{
		
	}
	
	public var ifList 					: Array<String> = null;
	public var ifNotList 				: Array<String> = null;
	
	public var exceptionReporter		: IAssemblingExceptionReporter;
}