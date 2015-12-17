package hex.ioc.parser.xml.mock;

import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.domain.DomainExpert;
import hex.event.IEvent;
import hex.event.IEventDispatcher;
import hex.module.IModule;
import hex.module.IModuleListener;
import hex.module.ModuleEvent;

/**
 * ...
 * @author Francis Bourre
 */
class MockModule implements IModule implements IModuleListener
{
	private var _domainDispatcher 	: IEventDispatcher<IModuleListener, IEvent>;
	
	public function new() 
	{
		this._domainDispatcher = ApplicationDomainDispatcher.getInstance().getDomainDispatcher( this.getDomain() );
	
		if ( this._domainDispatcher != null )
		{
			this._domainDispatcher.addListener( this );
		}
	}
	
	public function dispatchDomainEvent( e : IEvent ) : Void
	{
		this._domainDispatcher.dispatchEvent( e );
	}
	
	public function getDomain() : Domain
	{
		return DomainExpert.getInstance().getDomainFor( this );
	}
	
	public function initialize() : Void 
	{
		
	}
	
	public var isInitialized( get, null ) : Bool;
	
	function get_isInitialized() : Bool 
	{
		return isInitialized;
	}
	
	public function release() : Void 
	{
		
	}
	
	public var isReleased( get, null ) : Bool;
	
	function get_isReleased() : Bool 
	{
		return isReleased;
	}
	
	public function sendExternalEventFromDomain( e : ModuleEvent ) : Void 
	{
		
	}
	
	public function addHandler( type : String, callback : IEvent->Void ) : Void 
	{
		
	}
	
	public function removeHandler( type : String, callback:IEvent->Void ) : Void 
	{
		
	}
	
	
	/* INTERFACE hex.module.IModuleListener */
	
	public function onModuleInitialisation( e : ModuleEvent ) : Void 
	{
		
	}
	
	public function onModuleRelease( e : ModuleEvent ) : Void 
	{
		
	}
	
	public function handleEvent( e : IEvent ) : Void 
	{
		
	}
	
}