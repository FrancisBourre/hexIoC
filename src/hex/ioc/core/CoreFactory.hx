package hex.ioc.core;
import hex.collection.ILocator;
import hex.collection.ILocatorListener;

/**
 * ...
 * @author Francis Bourre
 */
class CoreFactory implements ILocator<Dynamic, Dynamic>
{

	public function new() 
	{
		
	}
	
	public function keys() : Array<Dynamic> 
	{
		
	}
	
	public function values() : Array<Dynamic> 
	{
		
	}
	
	public function isRegisteredWithKey( key : Dynamic ) : Bool 
	{
		
	}
	
	public function locate( key: Dynamic ) : Dynamic 
	{
		
	}
	
	public function register( key : Dynamic, element : Dynamic ) : Bool 
	{
		
	}
	
	public function unregister( key : Dynamic ) : Bool 
	{
		
	}
	
	public function add( map : Map<Dynamic, Dynamic> ) : Void 
	{
		
	}
	
	public function addListener( listener : ILocatorListener<Dynamic, Dynamic> ) : Bool 
	{
		
	}
	
	public function removeListener( listener : ILocatorListener<Dynamic, Dynamic> ) : Bool 
	{
		
	}
}