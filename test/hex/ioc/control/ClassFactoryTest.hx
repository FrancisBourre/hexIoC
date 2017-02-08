package hex.ioc.control;

import hex.error.IllegalArgumentException;
import hex.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.structures.Size;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ClassFactoryTest
{
	@Test( "Test execute" )
    public function testExecute() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Class", ["hex.structures.Size"] );
		Assert.equals( ClassFactory.build( helper ), Size, "constructorVO.result should be an instance of 'Size' class" );
	}
	
	@Test( "Test execute with invalid argument" )
    public function testExecuteWithInvalidArgument() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO = new ConstructorVO( "test", "Class", ["a"] );
		Assert.methodCallThrows( IllegalArgumentException, ClassFactory, ClassFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Class", null );
		Assert.methodCallThrows( IllegalArgumentException, ClassFactory, ClassFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Class", [] );
		Assert.methodCallThrows( IllegalArgumentException, ClassFactory, ClassFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Class", [null] );
		Assert.methodCallThrows( IllegalArgumentException, ClassFactory, ClassFactory.build, [ helper ], "command execution should throw IllegalArgumentException" );
	}
}