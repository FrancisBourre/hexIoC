package hex.ioc.control;

import hex.error.IllegalArgumentException;
import hex.ioc.vo.BuildHelperVO;
import hex.ioc.vo.ConstructorVO;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class BuildStringCommandTest
{
	@Test( "Test execute" )
    public function testExecute() : Void
    {
		var cmd = new BuildStringCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "String", ["hello world"] );
		cmd.execute( helper );
		Assert.equals( "hello world", helper.constructorVO.result, "constructorVO.result should equal 'hello world'" );
	}
	
	@Test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var cmd = new BuildStringCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "String", null );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var cmd = new BuildStringCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "String", [] );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var cmd = new BuildStringCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "String", [null] );
		Assert.methodCallThrows( IllegalArgumentException, cmd, cmd.execute, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with argument zero length" )
    public function testExecuteWithArgumentZeroLength() : Void
    {
		var cmd = new BuildStringCommand();
		var helper = new BuildHelperVO();
		helper.constructorVO 			= new ConstructorVO( "test", "String", [""] );
		cmd.execute( helper );
		Assert.equals( "", helper.constructorVO.result, "constructorVO.result should equal ''" );
	}
}