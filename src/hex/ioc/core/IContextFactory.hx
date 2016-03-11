package hex.ioc.core;

import hex.domain.IApplicationDomainDispatcher;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.control.IBuildCommand;
import hex.ioc.locator.DomainListenerVOLocator;
import hex.ioc.locator.PropertyVOLocator;
import hex.ioc.locator.StateTransitionVOLocator;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.StateTransitionVO;

/**
 * @author Francis Bourre
 */

interface IContextFactory 
{
	function registerID( id : String ) : Bool;
	
	function registerStateTransitionVO( id : String, stateTransitionVO : StateTransitionVO ) : Void;
	
	function buildStateTransition( key : String ) : Void;
	
	function buildAllStateTransitions() : Void;
	
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

	function getCoreFactory() : ICoreFactory;

	function getPropertyVOLocator() : PropertyVOLocator;

	function addType( type : String, build : Class<IBuildCommand> ) : Void;

	function build( constructorVO : ConstructorVO, ?id : String ) : Dynamic;

	function release() : Void;
}