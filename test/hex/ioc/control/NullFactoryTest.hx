package hex.ioc.control;

import hex.ioc.control.NullFactory;
import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.ConstructorVO;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class NullFactoryTest
{
	@Test( "Test execute" )
    public function testExecute() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test" );
		NullFactory.build( helper );
		Assert.isNull( helper.constructorVO.result, "constructorVO.result should be null" );
	}
}