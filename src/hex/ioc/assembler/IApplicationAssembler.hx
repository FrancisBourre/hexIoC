package hex.ioc.assembler;

import hex.ioc.core.BuilderFactory;
import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.ioc.vo.PropertyVO;

/**
 * @author Francis Bourre
 */
interface IApplicationAssembler 
{
	function getBuilderFactory( applicationContext : ApplicationContext ) : BuilderFactory;
	function release() : Void;
	function buildProperty( applicationContext : ApplicationContext, ownerID : String, name : String = null, value : String = null, type : String = null, ref : String = null, method : String = null, staticRef : String = null, ifList : Array<String> = null, ifNotList : Array<String> = null ) : PropertyVO;
	function buildObject( applicationContext : ApplicationContext, ownerID : String, type : String = null, args : Array<Dynamic> = null, factory : String = null, singleton : String = null, mapType : String = null, staticRef : String = null, ifList : Array<String> = null, ifNotList : Array<String> = null ) : ConstructorVO;
	function buildMethodCall( applicationContext : ApplicationContext, ownerID : String, methodCallName : String, args : Array<Dynamic> = null, ifList : Array<String> = null, ifNotList : Array<String> = null ) : Void;
	function buildDomainListener( applicationContext : ApplicationContext, ownerID : String, listenedDomainName : String, args : Array<DomainListenerVOArguments> = null, ifList : Array<String> = null, ifNotList : Array<String> = null ) : Void;
	function configureStateTransition( applicationContext : ApplicationContext, ID : String, staticReference : String, instanceReference : String, enterList : Array<CommandMappingVO>, exitList : Array<CommandMappingVO>, ifList : Array<String> = null, ifNotList : Array<String> = null ) : Void;
	
	function buildEverything() : Void;
	function getApplicationContext( applicationContextName : String, applicationContextClass : Class<ApplicationContext> = null ) : ApplicationContext;
	

	function setStrictMode( b : Bool ) : Void;
	public function isInStrictMode() : Bool;
	function addConditionalProperty( conditionalProperties : Map<String, Bool> ) : Void;
	function allowsIfList( ifList : Array<String> = null ) : Bool;
	function allowsIfNotList( ifNotList : Array<String> = null ) : Bool;
}