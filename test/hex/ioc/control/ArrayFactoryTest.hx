package hex.ioc.control;

import hex.core.IApplicationContext;
import hex.core.ICoreFactory;
import hex.ioc.core.IContextFactory;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.TransitionVO;
import hex.metadata.IAnnotationProvider;
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
		var helper = new FactoryVO();
		helper.contextFactory = new MockContextFactory();
		
		helper.constructorVO = new ConstructorVO( "test", "Array", 
			[ 
				new ConstructorVO( "test", "Int", [3] ), 
				new ConstructorVO( "test", 'String', ['hello world'] )
			] );
		
		var result = ArrayFactory.build( helper );
		Assert.isInstanceOf( result, Array );
		Assert.equals( 2, result.length );
		Assert.equals( 3, result[ 0 ] );
		Assert.equals( "hello world", result[ 1 ] );
	}
	
	@Test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var helper = new FactoryVO();
		helper.contextFactory = new MockContextFactory();
		
		helper.constructorVO = new ConstructorVO( "test", "Array", [] );
		var result = ArrayFactory.build( helper );
		Assert.isInstanceOf( result, Array );
	}
	
	@Test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var helper = new FactoryVO();
		helper.contextFactory = new MockContextFactory();
		
		helper.constructorVO = new ConstructorVO( "test", "Array", [] );
		var result = ArrayFactory.build( helper );
		Assert.isInstanceOf( result, Array );
	}
	
	@Test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var helper = new FactoryVO();
		helper.contextFactory = new MockContextFactory();

		helper.constructorVO = new ConstructorVO( "test", "Array", [ new ConstructorVO( '', "null" ) ] );
		var result = ArrayFactory.build( helper );
		Assert.isInstanceOf( result, Array );
		Assert.deepEquals( [null], result );
	}
}

private class MockContextFactory implements IContextFactory
{
	public function new()	
	{
		
	}
	
	public function buildVO( constructorVO : ConstructorVO, ?id : String ) : Dynamic
	{
		return constructorVO.arguments;
	}
	
	public function buildStateTransition( key : String ) : Array<TransitionVO>
	{
		return null;
	}
	
	public function buildObject( id : String ) : Void
	{
		
	}
	
	public function assignDomainListener( id : String ) : Bool
	{
		return false;
	}
	
	public function callMethod( id : String ) : Void
	{
		
	}
	
	public function getApplicationContext() : IApplicationContext
	{
		return null;
	}
	
	public function getAnnotationProvider() : IAnnotationProvider
	{
		return null;
	}

	public function getCoreFactory() : ICoreFactory
	{
		return null;
	}
}