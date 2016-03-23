package hex.ioc.vo;

import hex.ioc.core.IContextFactory;
import hex.ioc.core.ICoreFactory;
import hex.ioc.locator.ModuleLocator;

/**
 * ...
 * @author Francis Bourre
 */
class BuildHelperVO
{
	public var type 					: String;
	public var contextFactory 			: IContextFactory;
	public var coreFactory				: ICoreFactory;
	public var constructorVO 			: ConstructorVO;
	public var moduleLocator			: ModuleLocator;

	public function new() 
	{
		
	}
}