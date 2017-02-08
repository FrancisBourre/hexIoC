package hex.ioc.control;

import hex.ioc.control.NullFactory;
import hex.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
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
		Assert.isNull( NullFactory.build( helper ), "constructorVO.result should be null" );
	}
}