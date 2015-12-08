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
	@test( "Test execute" )
    public function testExecute() : Void
    {
		var cmd : BuildNullCommand 	= new BuildNullCommand();
		var helper : BuildHelperVO 	= new BuildHelperVO();
		helper.constructorVO 		= new ConstructorVO( "test" );
		cmd.setHelper( helper );
		cmd.execute();
		Assert.isNull( helper.constructorVO.result, "constructorVO.result should be null" );
	}
}