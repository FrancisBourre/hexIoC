package hex.ioc.assembler;

import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.DomainListenerVOArguments;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeApplicationAssembler implements IApplicationAssembler
{
	public function new() 
	{
		
	}
	
	public function release() : Void
	{
		
	}
	
	public function buildProperty 			( 
												applicationContext 	: AbstractApplicationContext, 
												ownerID 			: String, 
												name 				: String = null, 
												value 				: String = null, 
												type 				: String = null, 
												ref 				: String = null, 
												method 				: String = null, 
												staticRef 			: String = null, 
												ifList 				: Array<String> = null, 
												ifNotList 			: Array<String> = null 
											) : Void
	{
		//
	}
	
	public function buildObject				( 
												applicationContext 	: AbstractApplicationContext, 
												ownerID 			: String, 
												type 				: String = null, 
												args 				: Array<Dynamic> = null, 
												factory 			: String = null, 
												singleton 			: String = null, 
												injectInto 			: Bool = false, 
												mapType 			: String = null, 
												staticRef 			: String = null, 
												ifList 				: Array<String> = null, 
												ifNotList 			: Array<String> = null 
											) : Void
	{
		//
	}
	
	public function buildMethodCall			( 
												applicationContext 	: AbstractApplicationContext, 
												ownerID 			: String, 
												methodCallName 		: String, 
												args 				: Array<Dynamic> = null, 
												ifList 				: Array<String> = null, 
												ifNotList 			: Array<String> = null 
											) : Void
	{
		//
	}
	
	public function buildDomainListener 	( 
												applicationContext 	: AbstractApplicationContext, 
												ownerID 			: String, 
												listenedDomainName 	: String, 
												args 				: Array<DomainListenerVOArguments> = null, 
												ifList 				: Array<String> = null, 
												ifNotList 			: Array<String> = null 
											) : Void
	{
		//
	}
	
	public function configureStateTransition( 
												applicationContext 	: AbstractApplicationContext, 
												ID 					: String, 
												staticReference 	: String, 
												instanceReference 	: String, 
												enterList 			: Array<CommandMappingVO>, 
												exitList 			: Array<CommandMappingVO>, 
												ifList 				: Array<String> = null, 
												ifNotList 			: Array<String> = null 
											) : Void
	{
		
	}
	
	public function buildEverything() : Void
	{
		
	}
	
	public function getApplicationContext( applicationContextName : String, applicationContextClass : Class<AbstractApplicationContext> = null ) : AbstractApplicationContext
	{
		return null;
	}
	

	public function setStrictMode( b : Bool ) : Void
	{
		
	}
	
	public function isInStrictMode() : Bool
	{
		return true;
	}
	
	public function addConditionalProperty( conditionalProperties : Map<String, Bool> ) : Void
	{
		
	}
	
	public function allowsIfList( ifList : Array<String> = null ) : Bool
	{
		return true;
	}
	
	public function allowsIfNotList( ifNotList : Array<String> = null ) : Bool
	{
		return true;
	}
}