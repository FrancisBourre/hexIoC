package hex.ioc.vo;

import hex.core.ICoreFactory;
import hex.ioc.core.IContextFactory;

/**
 * ...
 * @author Francis Bourre
 */
class FactoryVO
{
	public var type 					: String;
	public var contextFactory 			: IContextFactory;
	public var coreFactory				: ICoreFactory;
	public var constructorVO 			: ConstructorVO;

	public function new() 
	{
		
	}
}