package hex.factory;

import hex.ioc.vo.AssemblerVO;

/**
 * ...
 * @author Francis Bourre
 */
class MockAssemblerVO extends AssemblerVO
{
	public var isConstructed : Bool = false;
	
	public function new() 
	{
		super();
	}
}