package hex.ioc.control;

import hex.error.IllegalArgumentException;
import hex.ioc.control.BuildIntCommand;
import hex.ioc.vo.BuildHelperVO;
import hex.ioc.vo.ConstructorVO;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class BuildIntcommandTest
{
	@test( "Test execute with positive value" )
    public function testExecuteWithPositiveValue() : Void
    {
		var cmd : BuildIntCommand 	= new BuildIntCommand();
		var helper : BuildHelperVO 	= new BuildHelperVO();
		helper.constructorVO 		= new ConstructorVO( "test", "Int", ["4"] );
		cmd.setHelper( helper );
		cmd.execute();
		Assert.equals( 4, helper.constructorVO.result, "constructorVO.result should equal 4" );
	}
	
	@test( "Test execute with negative value" )
    public function testExecuteWithNegativeValue() : Void
    {
		var cmd : BuildIntCommand 	= new BuildIntCommand();
		var helper : BuildHelperVO 	= new BuildHelperVO();
		helper.constructorVO 		= new ConstructorVO( "test", "Int", ["-4"] );
		cmd.setHelper( helper );
		cmd.execute();
		Assert.equals( -4, helper.constructorVO.result, "constructorVO.result should equal -4" );
	}
	
	@test( "Test execute with invalid argument" )
    public function testExecuteWithInvalidArgument() : Void
    {
		var cmd : BuildIntCommand 	= new BuildIntCommand();
		var helper : BuildHelperVO 	= new BuildHelperVO();
		helper.constructorVO 		= new ConstructorVO( "test", "Int", ["a"] );
		cmd.setHelper( helper );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [], "command execution should throw IllegalArgumentException" );
	}
	
	@test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var cmd : BuildIntCommand 		= new BuildIntCommand();
		var helper : BuildHelperVO 		= new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Int", null );
		cmd.setHelper( helper );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [], "command execution should throw IllegalArgumentException" );
	}
	
	@test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var cmd : BuildIntCommand 		= new BuildIntCommand();
		var helper : BuildHelperVO 		= new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Int", [] );
		cmd.setHelper( helper );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [], "command execution should throw IllegalArgumentException" );
	}
	
	@test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var cmd : BuildIntCommand 		= new BuildIntCommand();
		var helper : BuildHelperVO 		= new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Int", [null] );
		cmd.setHelper( helper );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [], "command execution should throw IllegalArgumentException" );
	}
}