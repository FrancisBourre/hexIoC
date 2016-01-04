package hex.ioc.control;

import hex.error.IllegalArgumentException;
import hex.ioc.vo.BuildHelperVO;
import hex.ioc.vo.ConstructorVO;
import hex.structures.Point;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class BuildClassCommandTest
{
	@test( "Test execute" )
    public function testExecute() : Void
    {
		var cmd : BuildClassCommand 	= new BuildClassCommand();
		var helper : BuildHelperVO 		= new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Class", ["hex.structures.Point"] );
		cmd.setHelper( helper );
		cmd.execute();
		Assert.equals( helper.constructorVO.result, Point, "constructorVO.result should be an instance of Point class" );
	}
	
	@test( "Test execute with invalid argument" )
    public function testExecuteWithInvalidArgument() : Void
    {
		var cmd : BuildClassCommand 	= new BuildClassCommand();
		var helper : BuildHelperVO 		= new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Class", ["a"] );
		cmd.setHelper( helper );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [], "command execution should throw IllegalArgumentException" );
	}
	
	@test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var cmd : BuildClassCommand 	= new BuildClassCommand();
		var helper : BuildHelperVO 		= new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Class", null );
		cmd.setHelper( helper );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [], "command execution should throw IllegalArgumentException" );
	}
	
	@test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var cmd : BuildClassCommand 	= new BuildClassCommand();
		var helper : BuildHelperVO 		= new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Class", [] );
		cmd.setHelper( helper );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [], "command execution should throw IllegalArgumentException" );
	}
	
	@test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var cmd : BuildClassCommand 	= new BuildClassCommand();
		var helper : BuildHelperVO 		= new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Class", [null] );
		cmd.setHelper( helper );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [], "command execution should throw IllegalArgumentException" );
	}
}