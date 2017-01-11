package hex.ioc.control;

import hex.error.IllegalArgumentException;
import hex.ioc.control.IntFactory;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class IntFactoryTest
{
	@Test( "Test execute with positive value" )
    public function testExecuteWithPositiveValue() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "Int", ["4"] );
		Assert.equals( 4, IntFactory.build( helper ), "constructorVO.result should equal 4" );
	}
	
	@Test( "Test execute with negative value" )
    public function testExecuteWithNegativeValue() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "Int", ["-4"] );
		Assert.equals( -4, IntFactory.build( helper ), "constructorVO.result should equal -4" );
	}
	
	@Test( "Test execute with invalid argument" )
    public function testExecuteWithInvalidArgument() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "Int", ["a"] );
		Assert.methodCallThrows( IllegalArgumentException, IntFactory, IntFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "Int", null );
		Assert.methodCallThrows( IllegalArgumentException, IntFactory, IntFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "Int", [] );
		Assert.methodCallThrows( IllegalArgumentException, IntFactory, IntFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "Int", [ null ] );
		Assert.methodCallThrows( IllegalArgumentException, IntFactory, IntFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
}