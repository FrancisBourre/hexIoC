package hex.ioc.vo;

import hex.ioc.core.IBuilderFactory;
import hex.ioc.core.ICoreFactory;
import hex.ioc.core.ModuleLocator;

/**
 * ...
 * @author Francis Bourre
 */
class BuildHelperVO
{
	public var type 					: String;
	public var builderFactory 			: IBuilderFactory;
	public var coreFactory				: ICoreFactory;
	public var constructorVO 			: ConstructorVO;
	public var moduleLocator			: ModuleLocator;

	public function new() 
	{
		
	}
}