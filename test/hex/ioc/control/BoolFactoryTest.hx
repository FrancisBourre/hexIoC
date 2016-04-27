package hex.ioc.control;

import hex.error.IllegalArgumentException;
import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.ConstructorVO;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class BoolFactoryTest
{
	@Test( "Test execute with true argument" )
    public function testExecuteWithTrueArgument() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Bool", ["true"] );
		BoolFactory.build( helper );
		Assert.isTrue( helper.constructorVO.result, "constructorVO.result should be true" );
	}
	
	@Test( "Test execute with false argument" )
    public function testExecuteWithFalseArgument() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Bool", ["false"] );
		BoolFactory.build( helper );
		Assert.isFalse( helper.constructorVO.result, "constructorVO.result should be false" );
	}
	
	@Test( "Test execute with invalid argument" )
    public function testExecuteWithInvalidArgument() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Bool", ["a"] );
		Assert.methodCallThrows( IllegalArgumentException, BoolFactory, BoolFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Bool", null );
		Assert.methodCallThrows( IllegalArgumentException, BoolFactory, BoolFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Bool", [] );
		Assert.methodCallThrows( IllegalArgumentException, BoolFactory, BoolFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Bool", [null] );
		Assert.methodCallThrows( IllegalArgumentException, BoolFactory, BoolFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
}