package hex.factory;

/**
 * @author Francis Bourre
 */
enum BuildRequest 
{
	PREPROCESS( vo : hex.vo.PreProcessVO );
	OBJECT( vo : hex.vo.ConstructorVO );
	PROPERTY( vo : hex.vo.PropertyVO );
	METHOD_CALL( vo : hex.vo.MethodCallVO );
	DOMAIN_LISTENER( vo : hex.ioc.vo.DomainListenerVO );
	STATE_TRANSITION( vo : hex.ioc.vo.StateTransitionVO );
}