package hex.ioc.control;

import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.ConstructorVO;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ArrayFactoryTest
{
	@Test( "Test executet" )
    public function testExecute() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Array", [3, "hello world"] );
		ArrayFactory.build( helper );
		Assert.isInstanceOf( helper.constructorVO.result, Array, "constructorVO.result should be an instance of Array class" );
		Assert.deepEquals( [3, "hello world"], helper.constructorVO.result, "constructorVO.result should agregate the same elements" );
	}
	
	@Test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Array", null );
		ArrayFactory.build( helper );
		Assert.isInstanceOf( helper.constructorVO.result, Array, "constructorVO.result should be an instance of Array class" );
	}
	
	@Test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Array", [] );
		ArrayFactory.build( helper );
		Assert.isInstanceOf( helper.constructorVO.result, Array, "constructorVO.result should be an instance of Array class" );
	}
	
	@Test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var helper = new FactoryVO();
		helper.constructorVO 			= new ConstructorVO( "test", "Array", [null] );
		ArrayFactory.build( helper );
		Assert.isInstanceOf( helper.constructorVO.result, Array, "constructorVO.result should be an instance of Array class" );
		Assert.deepEquals( [null], helper.constructorVO.result, "constructorVO.result should agregate the same elements" );
	}
}