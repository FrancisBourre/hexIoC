package hex.ioc.control;

import hex.ioc.core.ContextFactory;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ArrayFactoryTest
{
	@Test( "Test execute" )
    public function testExecute() : Void
    {
		var factoryVO = new FactoryVO();
		factoryVO.contextFactory = new MockContextFactory();
		
		factoryVO.constructorVO = new ConstructorVO( "test", "Array", 
			[ 
				new ConstructorVO( "test", "Int", [3] ), 
				new ConstructorVO( "test", 'String', ['hello world'] )
			] );
		
		var result = ArrayFactory.build( factoryVO );
		Assert.isInstanceOf( result, Array, "constructorVO.result should be an instance of Array class" );
		Assert.deepEquals( [3, "hello world"], result, "constructorVO.result should agregate the same elements" );
	}
	
	@Test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var factoryVO = new FactoryVO();
		factoryVO.contextFactory = new MockContextFactory();
		
		factoryVO.constructorVO = new ConstructorVO( "test", "Array", [] );
		var result = ArrayFactory.build( factoryVO );
		Assert.isInstanceOf( result, Array, "constructorVO.result should be an instance of Array class" );
	}
	
	@Test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var factoryVO = new FactoryVO();
		factoryVO.contextFactory = new MockContextFactory();
		
		factoryVO.constructorVO = new ConstructorVO( "test", "Array", [] );
		var result = ArrayFactory.build( factoryVO );
		Assert.isInstanceOf( result, Array, "constructorVO.result should be an instance of Array class" );
	}
	
	@Test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var factoryVO = new FactoryVO();
		factoryVO.contextFactory = new MockContextFactory();

		factoryVO.constructorVO = new ConstructorVO( "test", "Array", [ new ConstructorVO( '', "null" ) ] );
		var result = ArrayFactory.build( factoryVO );
		Assert.isInstanceOf( result, Array, "constructorVO.result should be an instance of Array class" );
		Assert.deepEquals( [null], result, "constructorVO.result should agregate the same elements" );
	}
}

private class MockContextFactory extends ContextFactory
{
	public function new()	
	{
		super();
	}
	
	override public function buildVO( constructorVO : ConstructorVO, ?id : String ) : Dynamic
	{
		return constructorVO.arguments != null ? constructorVO.arguments[ 0 ] : null;
	}
}