package hex.factory;

import hex.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.vo.MethodCallVO;
import hex.vo.PropertyVO;
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