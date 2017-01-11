package hex.ioc.control;

import hex.error.IllegalArgumentException;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class StringFactoryTest
{
	@Test( "Test execute" )
    public function testExecute() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "String", ["hello world"] );
		Assert.equals( "hello world", StringFactory.build( helper ), "constructorVO.result should equal 'hello world'" );
	}
	
	@Test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "String", null );
		Assert.methodCallThrows( IllegalArgumentException, StringFactory, StringFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "String", [] );
		Assert.methodCallThrows( IllegalArgumentException, StringFactory, StringFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "String", [null] );
		Assert.methodCallThrows( IllegalArgumentException, StringFactory, StringFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with argument zero length" )
    public function testExecuteWithArgumentZeroLength() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "String", [""] );
		Assert.equals( "", StringFactory.build( helper ), "constructorVO.result should equal ''" );
	}
}