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
	@Test( "Test execute" )
    public function testExecute() : Void
    {
		var cmd = new BuildClassCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Class", ["hex.structures.Point"] );
		cmd.execute( helper );
		Assert.equals( helper.constructorVO.result, Point, "constructorVO.result should be an instance of Point class" );
	}
	
	@Test( "Test execute with invalid argument" )
    public function testExecuteWithInvalidArgument() : Void
    {
		var cmd = new BuildClassCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Class", ["a"] );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var cmd = new BuildClassCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Class", null );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var cmd = new BuildClassCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Class", [] );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var cmd = new BuildClassCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Class", [null] );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [ helper ], "command execution should throw IllegalArgumentException" );
	}
}