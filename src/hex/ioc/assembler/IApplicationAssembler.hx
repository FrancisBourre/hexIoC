package hex.ioc.assembler;

import hex.ioc.core.BuilderFactory;
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
	function buildProperty( applicationContext : ApplicationContext, ownerID : String, name : String = null, value : String = null, type : String = null, ref : String = null, method : String = null, staticRef : String = null ) : PropertyVO;
	function buildObject( applicationContext : ApplicationContext, ownerID : String, type : String = null, args : Array<Dynamic> = null, factory : String = null, singleton : String = null, mapType : String = null, staticRef : String = null ) : ConstructorVO;
	function buildMethodCall( applicationContext : ApplicationContext, ownerID : String, methodCallName : String, args : Array<Dynamic> = null ) : Void;
	function buildDomainListener( applicationContext : ApplicationContext, ownerID : String, listenedDomainName : String, args : Array<DomainListenerVOArguments> = null ) : Void;
	function registerID( applicationContext : ApplicationContext, ID : String ) : Bool;
	function buildEverything() : Void;
	function getApplicationContext( applicationContextName : String, applicationContextClass : Class<ApplicationContext> = null ) : ApplicationContext;
}