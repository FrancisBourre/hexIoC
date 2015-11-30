package hex.ioc.vo;

import hex.ioc.core.BuilderFactory;
import hex.ioc.core.CoreFactory;
import hex.ioc.core.ModuleLocator;

/**
 * ...
 * @author Francis Bourre
 */
class BuildHelperVO
{
	public var type 					: String;
	public var builderFactory 			: BuilderFactory;
	public var coreFactory				: CoreFactory;
	public var constructorVO 			: ConstructorVO;
	public var moduleLocator			: ModuleLocator;

	public function new() 
	{
		
	}
}