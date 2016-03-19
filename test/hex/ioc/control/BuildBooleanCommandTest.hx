package hex.ioc.control;

import hex.error.IllegalArgumentException;
import hex.ioc.vo.BuildHelperVO;
import hex.ioc.vo.ConstructorVO;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class BuildBooleanCommandTest
{
	@Test( "Test execute with true argument" )
    public function testExecuteWithTrueArgument() : Void
    {
		var cmd = new BuildBooleanCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Bool", ["true"] );
		cmd.execute( helper );
		Assert.isTrue( helper.constructorVO.result, "constructorVO.result should be true" );
	}
	
	@Test( "Test execute with false argument" )
    public function testExecuteWithFalseArgument() : Void
    {
		var cmd = new BuildBooleanCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Bool", ["false"] );
		cmd.execute( helper );
		Assert.isFalse( helper.constructorVO.result, "constructorVO.result should be false" );
	}
	
	@Test( "Test execute with invalid argument" )
    public function testExecuteWithInvalidArgument() : Void
    {
		var cmd = new BuildBooleanCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Bool", ["a"] );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var cmd = new BuildBooleanCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Bool", null );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var cmd = new BuildBooleanCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Bool", [] );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var cmd = new BuildBooleanCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Bool", [null] );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [ helper ], "command execution should throw IllegalArgumentException" );
	}
}