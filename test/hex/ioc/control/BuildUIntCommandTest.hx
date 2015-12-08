package hex.ioc.control;

import hex.error.IllegalArgumentException;
import hex.ioc.vo.BuildHelperVO;
import hex.ioc.vo.ConstructorVO;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class BuildUIntCommandTest
{
	@test( "Test execute" )
    public function testExecute() : Void
    {
		var cmd : BuildUIntCommand 	= new BuildUIntCommand();
		var helper : BuildHelperVO 	= new BuildHelperVO();
		helper.constructorVO 		= new ConstructorVO( "test", "UInt", ["4"] );
		cmd.setHelper( helper );
		cmd.execute();
		Assert.equals( 4, helper.constructorVO.result, "constructorVO.result should equal 4" );
	}
	
	@ignore( "Test execute with negative argument value" )
    public function testExecuteWithNegativeArgumentValue() : Void
    {
		var cmd : BuildUIntCommand 	= new BuildUIntCommand();
		var helper : BuildHelperVO 	= new BuildHelperVO();
		helper.constructorVO 		= new ConstructorVO( "test", "UInt", ["-4"] );
		cmd.setHelper( helper );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [], "command execution should throw IllegalArgumentException" );
	}
	
	@test( "Test execute with invalid argument" )
    public function testExecuteWithInvalidArgument() : Void
    {
		var cmd : BuildUIntCommand 	= new BuildUIntCommand();
		var helper : BuildHelperVO 	= new BuildHelperVO();
		helper.constructorVO 		= new ConstructorVO( "test", "UInt", ["a"] );
		cmd.setHelper( helper );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [], "command execution should throw IllegalArgumentException" );
	}
	
	@test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var cmd : BuildUIntCommand 		= new BuildUIntCommand();
		var helper : BuildHelperVO 		= new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "UInt", null );
		cmd.setHelper( helper );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [], "command execution should throw IllegalArgumentException" );
	}
	
	@test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var cmd : BuildUIntCommand 		= new BuildUIntCommand();
		var helper : BuildHelperVO 		= new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "UInt", [] );
		cmd.setHelper( helper );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [], "command execution should throw IllegalArgumentException" );
	}
	
	@test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var cmd : BuildUIntCommand 		= new BuildUIntCommand();
		var helper : BuildHelperVO 		= new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "UInt", [null] );
		cmd.setHelper( helper );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [], "command execution should throw IllegalArgumentException" );
	}
}