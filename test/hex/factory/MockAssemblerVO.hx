package hex.factory;

import hex.vo.AssemblerVO;

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