package hex.ioc.core;

import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;
import hex.ioc.vo.StateTransitionVO;
import hex.metadata.IAnnotationProvider;

/**
 * @author Francis Bourre
 */
interface IContextFactory 
{
	function registerID( id : String ) : Bool;
	
	function registerStateTransitionVO( id : String, stateTransitionVO : StateTransitionVO ) : Void;
	
	function buildStateTransition( key : String ) : Void;
	
	function buildAllStateTransitions() : Void;
	
	function registerPropertyVO( id : String, propertyVO : PropertyVO  ) : Void;
	
	function registerConstructorVO( id : String, constructorVO : ConstructorVO ) : Void;
	
	function buildObject( id : String ) : Void;
	
	function buildAllObjects() : Void;
	
	function registerDomainListenerVO( domainListenerVO : DomainListenerVO ) : Void;
	
	function assignDomainListener( id : String ) : Bool;
	
	function assignAllDomainListeners() : Void;
	
	function registerMethodCallVO( methodCallVO : MethodCallVO ) : Void;
	
	function callMethod( id : String ) : Void;
	
	function callAllMethods() : Void;
	
	function callModuleInitialisation() : Void;
	
	function getApplicationContext() : AbstractApplicationContext;
	
	function getAnnotationProvider() : IAnnotationProvider;

	function getCoreFactory() : ICoreFactory;

	function release() : Void;
}