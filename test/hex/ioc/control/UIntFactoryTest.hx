package hex.ioc.control;

import hex.error.IllegalArgumentException;
import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.ConstructorVO;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class UIntFactoryTest
{
	@Test( "Test execute" )
    public function testExecute() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 		= new ConstructorVO( "test", "UInt", ["4"] );
		UIntFactory.build( helper );
		Assert.equals( 4, helper.constructorVO.result, "constructorVO.result should equal 4" );
	}
	
	@Ignore( "Test execute with negative argument value" )
    public function testExecuteWithNegativeArgumentValue() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 		= new ConstructorVO( "test", "UInt", ["-4"] );
		Assert.methodCallThrows( IllegalArgumentException, UIntFactory, UIntFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with invalid argument" )
    public function testExecuteWithInvalidArgument() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 		= new ConstructorVO( "test", "UInt", ["a"] );
		Assert.methodCallThrows( IllegalArgumentException, UIntFactory, UIntFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "UInt", null );
		Assert.methodCallThrows( IllegalArgumentException, UIntFactory, UIntFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "UInt", [] );
		Assert.methodCallThrows( IllegalArgumentException, UIntFactory, UIntFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "UInt", [null] );
		Assert.methodCallThrows( IllegalArgumentException, UIntFactory, UIntFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
}