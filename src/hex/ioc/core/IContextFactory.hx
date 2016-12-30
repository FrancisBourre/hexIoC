package hex.ioc.core;

import hex.factory.IProxyFactory;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;
import hex.ioc.vo.StateTransitionVO;
import hex.ioc.vo.TransitionVO;
import hex.metadata.IAnnotationProvider;

/**
 * @author Francis Bourre
 */
interface IContextFactory extends IProxyFactory
{
	function buildEverything() : Void;
	
	function registerID( id : String ) : Bool;
	
	function buildStateTransition( key : String ) : Array<TransitionVO>;
	
	function buildObject( id : String ) : Void;
	
	function assignDomainListener( id : String ) : Bool;
	
	function callMethod( id : String ) : Void;
	
	function getApplicationContext() : AbstractApplicationContext;
	
	function getAnnotationProvider() : IAnnotationProvider;

	function getCoreFactory() : ICoreFactory;

	function release() : Void;
	
	function getSymbolTable() : SymbolTable;
}
