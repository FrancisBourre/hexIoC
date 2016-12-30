package hex.ioc.parser.xml;

import hex.factory.ProxyFactory;
import hex.ioc.core.ContextFactory;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;
import hex.ioc.vo.StateTransitionVO;

/**
 * ...
 * @author Francis Bourre
 */
class XmlProxyFactory extends ProxyFactory
{
	public function new( contextFactory : ContextFactory ) 
	{
		super();
		
		this.registerFactoryMethod( PropertyVO, contextFactory.registerPropertyVO );
		this.registerFactoryMethod( ConstructorVO, contextFactory.registerConstructorVO );
		this.registerFactoryMethod( MethodCallVO, contextFactory.registerMethodCallVO );
		this.registerFactoryMethod( DomainListenerVO, contextFactory.registerDomainListenerVO );
		this.registerFactoryMethod( StateTransitionVO, contextFactory.registerStateTransitionVO );
	}
}