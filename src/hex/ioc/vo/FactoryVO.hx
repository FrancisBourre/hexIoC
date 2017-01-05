package hex.ioc.vo;

#if macro
import haxe.macro.Expr;
import hex.ioc.locator.ModuleLocator;
#end

import hex.ioc.core.IContextFactory;
import hex.core.ICoreFactory;

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
	public var expressions 				: Array<Expr>;
	#end

	public function new() 
	{
		
	}
}