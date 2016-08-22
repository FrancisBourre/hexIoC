package hex.ioc.assembler;

import hex.ioc.core.IContextFactory;
import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;
import hex.ioc.vo.StateTransitionVO;

/**
 * @author Francis Bourre
 */
interface IApplicationAssembler 
{
	function getContextFactory( applicationContext : AbstractApplicationContext ) : IContextFactory;
	function buildEverything() : Void;
	function release() : Void;
	function buildProperty( applicationContext : AbstractApplicationContext, propertyVO : PropertyVO ) : Void;
	function buildObject( applicationContext : AbstractApplicationContext, constructorVO : ConstructorVO ) : Void;
	function buildMethodCall( applicationContext : AbstractApplicationContext, methodCallVO : MethodCallVO ) : Void;
	function buildDomainListener( applicationContext : AbstractApplicationContext, domainListenerVO : DomainListenerVO ) : Void;
	function configureStateTransition( applicationContext : AbstractApplicationContext, stateTransitionVO : StateTransitionVO ) : Void;
	function getApplicationContext( applicationContextName : String, applicationContextClass : Class<AbstractApplicationContext> = null ) : AbstractApplicationContext;
}