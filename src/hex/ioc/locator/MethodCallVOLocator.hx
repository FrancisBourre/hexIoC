package hex.ioc.locator;

import hex.collection.Locator;
import hex.collection.LocatorEvent;
import hex.ioc.core.BuilderFactory;
import hex.ioc.core.ContextTypeList;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.MethodCallVO;

/**
 * ...
 * @author Francis Bourre
 */
class MethodCallVOLocator extends Locator<String, MethodCallVO, LocatorEvent<String, MethodCallVO>>
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
		Reflect.callMethod( this._builderFactory.getCoreFactory().locate( method.ownerID ), func, args );
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
	
	override function _dispatchRegisterEvent( key : String, element : MethodCallVO ) : Void 
	{
		this._dispatcher.dispatchEvent( new LocatorEvent( LocatorEvent.REGISTER, this, key, element ) );
	}
	
	override function _dispatchUnregisterEvent( key : String ) : Void 
	{
		this._dispatcher.dispatchEvent( new LocatorEvent( LocatorEvent.UNREGISTER, this, key ) );
	}
}