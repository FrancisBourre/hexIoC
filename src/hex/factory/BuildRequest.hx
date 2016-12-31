package hex.factory;

import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;
import hex.ioc.vo.StateTransitionVO;

/**
 * @author Francis Bourre
 */
enum BuildRequest 
{
	OBJECT( vo : ConstructorVO );
	PROPERTY( vo : PropertyVO );
	METHOD_CALL( vo : MethodCallVO );
	DOMAIN_LISTENER( vo : DomainListenerVO );
	STATE_TRANSITION( vo : StateTransitionVO );
}