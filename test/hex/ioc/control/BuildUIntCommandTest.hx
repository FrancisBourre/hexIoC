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
	@Test( "Test execute" )
    public function testExecute() : Void
    {
		var cmd = new BuildUIntCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 		= new ConstructorVO( "test", "UInt", ["4"] );
		cmd.execute( helper );
		Assert.equals( 4, helper.constructorVO.result, "constructorVO.result should equal 4" );
	}
	
	@Ignore( "Test execute with negative argument value" )
    public function testExecuteWithNegativeArgumentValue() : Void
    {
		var cmd = new BuildUIntCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 		= new ConstructorVO( "test", "UInt", ["-4"] );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with invalid argument" )
    public function testExecuteWithInvalidArgument() : Void
    {
		var cmd = new BuildUIntCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 		= new ConstructorVO( "test", "UInt", ["a"] );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var cmd = new BuildUIntCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "UInt", null );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var cmd = new BuildUIntCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "UInt", [] );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var cmd = new BuildUIntCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "UInt", [null] );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [ helper ], "command execution should throw IllegalArgumentException" );
	}
}