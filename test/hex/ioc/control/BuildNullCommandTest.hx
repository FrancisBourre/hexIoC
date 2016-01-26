package hex.ioc.control;

import hex.ioc.control.BuildNullCommand;
import hex.ioc.vo.BuildHelperVO;
import hex.ioc.vo.ConstructorVO;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class BuildNullCommandTest
{
	@Test( "Test execute" )
    public function testExecute() : Void
    {
		var cmd = new BuildNullCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 		= new ConstructorVO( "test" );
		cmd.setHelper( helper );
		cmd.execute();
		Assert.isNull( helper.constructorVO.result, "constructorVO.result should be null" );
	}
}