package hex.ioc.core;

import hex.collection.ILocatorListener;
import hex.di.IBasicInjector;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeCoreFactory implements ICoreFactory
{
	public function new() 
	{
		
	}
	
	public function getBasicInjector() : IBasicInjector 
	{
		return null;
	}
	
	public function clear() : Void 
	{
		
	}
	
	public function getClassReference( qualifiedClassName : String ) : Class<Dynamic> 
	{
		return null;
	}
	
	public function getStaticReference( qualifiedClassName : String ) : Dynamic
	{
		return null;
	}
	
	public function buildInstance( qualifiedClassName : String, ?args : Array<Dynamic>, ?factoryMethod : String, ?singletonAccess : String, ?instantiateUnmapped : Bool = false ) : Dynamic 
	{
		return null;
	}
	
	public function keys() : Array<String> 
	{
		return null;
	}
	
	public function values() : Array<Dynamic> 
	{
		return null;
	}
	
	public function isRegisteredWithKey( key : String ) : Bool 
	{
		return null;
	}
	
	public function locate( key : String ) : Dynamic 
	{
		return null;
	}
	
	public function register( key : String, element : Dynamic ) : Bool 
	{
		return null;
	}
	
	public function unregister( key: String ) : Bool 
	{
		return null;
	}
	
	public function add( map : Map<String, Dynamic> ) : Void 
	{
		
	}
	
	public function addListener( listener : ILocatorListener<String, Dynamic> ) : Bool 
	{
		return null;
	}
	
	public function removeListener( listener : ILocatorListener<String, Dynamic> ) : Bool 
	{
		return null;
	}
}