package hex.ioc.vo;

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