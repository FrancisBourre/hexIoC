package hex.ioc.control;

import hex.error.IllegalArgumentException;
import hex.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class FloatFactoryTest
{
	@Test( "Test execute with positive value" )
    public function testExecuteWithPositiveValue() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "Float", ["4.7"] );
		Assert.equals( 4.7, FloatFactory.build( helper ), "constructorVO.result should equal '4.7'" );
	}
	
	@Test( "Test execute with negative value" )
    public function testExecuteWithNegativeValue() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "Float", ["-3.8"] );
		Assert.equals( -3.8, FloatFactory.build( helper ), "constructorVO.result should equal '-3.8'" );
	}
	
	@Test( "Test execute with invalid argument" )
    public function testExecuteWithInvalidArgument() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "Float", ["a"] );
		Assert.methodCallThrows( IllegalArgumentException, FloatFactory, FloatFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "Float", null );
		Assert.methodCallThrows( IllegalArgumentException, FloatFactory, FloatFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "Float", [] );
		Assert.methodCallThrows( IllegalArgumentException, FloatFactory, FloatFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "Float", [null] );
		Assert.methodCallThrows( IllegalArgumentException, FloatFactory, FloatFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
}