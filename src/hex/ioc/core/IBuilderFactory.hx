package hex.ioc.core;

import hex.domain.IApplicationDomainDispatcher;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.control.IBuildCommand;
import hex.ioc.locator.ConstructorVOLocator;
import hex.ioc.locator.DomainListenerVOLocator;
import hex.ioc.locator.MethodCallVOLocator;
import hex.ioc.locator.PropertyVOLocator;
import hex.ioc.locator.StateTransitionVOLocator;
import hex.ioc.vo.ConstructorVO;

/**
 * @author Francis Bourre
 */

interface IBuilderFactory 
{
	function getApplicationContext() : AbstractApplicationContext;

	function getCoreFactory() : ICoreFactory;

	function getApplicationHub() : IApplicationDomainDispatcher;

	function getIDExpert() : IDExpert;

	function getConstructorVOLocator() : ConstructorVOLocator;

	function getPropertyVOLocator() : PropertyVOLocator;
	
	function getMethodCallVOLocator() : MethodCallVOLocator;
	
	function getDomainListenerVOLocator() : DomainListenerVOLocator;
	
	function getStateTransitionVOLocator() : StateTransitionVOLocator;
	
	function getModuleLocator() : ModuleLocator;
	
	function init( applicationContext : AbstractApplicationContext, coreFactory : ICoreFactory ) : Void;

	function addType( type : String, build : Class<IBuildCommand> ) : Void;

	function build( constructorVO : ConstructorVO, ?id : String ) : Dynamic;

	function release() : Void;
}