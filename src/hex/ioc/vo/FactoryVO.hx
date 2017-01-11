package hex.ioc.vo;

#if macro
import hex.ioc.locator.ModuleLocator;
#end

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

	#if macro
	public var moduleLocator			: ModuleLocator;
	#end

	public function new() 
	{
		
	}
}