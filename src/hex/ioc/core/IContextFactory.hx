package hex.ioc.core;

#if macro
import haxe.macro.Expr;
#end

import hex.core.IApplicationContext;
import hex.core.ICoreFactory;
import hex.core.SymbolTable;
import hex.ioc.vo.TransitionVO;
import hex.metadata.IAnnotationProvider;

/**
 * @author Francis Bourre
 */
interface IContextFactory
{
	function registerID( id : String ) : Bool;
	
	function buildStateTransition( key : String ) : Array<TransitionVO>;
	
	function buildObject( id : String ) : Void;
	
	function assignDomainListener( id : String ) : Bool;
	
	function callMethod( id : String ) : Void;
	
	function getApplicationContext() : IApplicationContext;
	
	function getAnnotationProvider() : IAnnotationProvider;

	function getCoreFactory() : ICoreFactory;
	
	function getSymbolTable() : SymbolTable;
	
	function init( applicationContextName : String, applicationContextClass : Class<IApplicationContext> = null ) : Void;
}
