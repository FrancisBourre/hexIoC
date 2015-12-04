package hex.ioc.locator;

import hex.collection.Locator;
import hex.ioc.core.BuilderFactory;
import hex.ioc.core.ContextTypeList;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.MethodCallVO;

/**
 * ...
 * @author Francis Bourre
 */
class MethodCallVOLocator extends Locator<String, MethodCallVO>
{
	private var _builderFactory : BuilderFactory;

	public function new( builderFactory : BuilderFactory )
	{
		super();
		this._builderFactory = builderFactory;
	}

	public function callMethod( id : String ) : Void
	{
		var method : MethodCallVO 	= this.locate( id );
		var cons : ConstructorVO 	= new ConstructorVO( null, ContextTypeList.FUNCTION, [ method.ownerID + "." + method.name ] );
		var func : Dynamic 			= this._builderFactory.build( cons );

		var args : Array<Dynamic> = this._builderFactory.getPropertyVOLocator().deserializeArguments( method.arguments );
		//func.apply( null, args );
		Reflect.callMethod( this.locate( method.ownerID ), func, args );
	}

	public function callAllMethods() : Void
	{
		var keyList : Array<String> = this.keys();
		for ( key in keyList )
		{
			this.callMethod(  key );
		}
		
		this.clear();
	}
}