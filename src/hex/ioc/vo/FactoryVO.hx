package hex.ioc.vo;

import hex.ioc.core.ContextFactory;
import hex.ioc.core.CoreFactory;

/**
 * ...
 * @author Francis Bourre
 */
class FactoryVO
{
	public var contextFactory 			: ContextFactory;
	public var coreFactory				: CoreFactory;
	public var constructorVO 			: ConstructorVO;

	public function new() 
	{
		
	}
}