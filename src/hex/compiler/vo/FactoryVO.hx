package hex.compiler.vo;

#if macro
import hex.compiler.core.CompileTimeContextFactory;
import hex.compiler.core.CompileTimeCoreFactory;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class FactoryVO
{
	public var contextFactory 			: CompileTimeContextFactory;
	public var coreFactory				: CompileTimeCoreFactory;
	public var constructorVO 			: ConstructorVO;

	public function new() 
	{
		
	}
}
#end