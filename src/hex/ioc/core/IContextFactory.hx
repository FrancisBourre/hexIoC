package hex.ioc.core;

import hex.core.IApplicationContext;
import hex.core.ICoreFactory;
import hex.ioc.vo.TransitionVO;
import hex.metadata.IAnnotationProvider;

/**
 * @author Francis Bourre
 */
interface IContextFactory
{
	function buildEverything() : Void;
	
	function registerID( id : String ) : Bool;
	
	function buildStateTransition( key : String ) : Array<TransitionVO>;
	
	function buildObject( id : String ) : Void;
	
	function assignDomainListener( id : String ) : Bool;
	
	function callMethod( id : String ) : Void;
	
	function getApplicationContext() : IApplicationContext;
	
	function getAnnotationProvider() : IAnnotationProvider;

	function getCoreFactory() : ICoreFactory;

	function release() : Void;
	
	function getSymbolTable() : SymbolTable;
}
