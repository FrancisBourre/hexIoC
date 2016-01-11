package hex.ioc.control;

import hex.ioc.vo.BuildHelperVO;
import hex.ioc.vo.ConstructorVO;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class BuildArrayCommandTest
{
	@test( "Test executet" )
    public function testExecute() : Void
    {
		var cmd : BuildArrayCommand 	= new BuildArrayCommand();
		var helper : BuildHelperVO 		= new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Array", [3, "hello world"] );
		cmd.setHelper( helper );
		cmd.execute();
		Assert.isInstanceOf( helper.constructorVO.result, Array, "constructorVO.result should be an instance of Array class" );
		Assert.deepEquals( [3, "hello world"], helper.constructorVO.result, "constructorVO.result should agregate the same elements" );
	}
	
	@test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var cmd : BuildArrayCommand 	= new BuildArrayCommand();
		var helper : BuildHelperVO 		= new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Array", null );
		cmd.setHelper( helper );
		cmd.execute();
		Assert.isInstanceOf( helper.constructorVO.result, Array, "constructorVO.result should be an instance of Array class" );
	}
	
	@test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var cmd : BuildArrayCommand 	= new BuildArrayCommand();
		var helper : BuildHelperVO 		= new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Array", [] );
		cmd.setHelper( helper );
		cmd.execute();
		Assert.isInstanceOf( helper.constructorVO.result, Array, "constructorVO.result should be an instance of Array class" );
	}
	
	@test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var cmd : BuildArrayCommand 	= new BuildArrayCommand();
		var helper : BuildHelperVO 		= new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Array", [null] );
		cmd.setHelper( helper );
		cmd.execute();
		Assert.isInstanceOf( helper.constructorVO.result, Array, "constructorVO.result should be an instance of Array class" );
		Assert.deepEquals( [null], helper.constructorVO.result, "constructorVO.result should agregate the same elements" );
	}
	
}