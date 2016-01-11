package hex.ioc.parser.xml.mock;

import hex.domain.Domain;
import hex.domain.DomainExpert;
import hex.domain.ApplicationDomainDispatcher;
import hex.event.Dispatcher;
import hex.event.IDispatcher;
import hex.event.IEvent;
import hex.event.IEventDispatcher;
import hex.event.MessageType;
import hex.module.IModule;
import hex.module.IModuleListener;
import hex.module.ModuleEvent;

/**
 * ...
 * @author Francis Bourre
 */
class MockModule implements IModule implements IModuleListener
{
	private var _domainDispatcher 	: IDispatcher<{}>;
	
	public function new() 
	{
		this._domainDispatcher = ApplicationDomainDispatcher.getInstance().getDomainDispatcher( this.getDomain() );
	
		/*if ( this._domainDispatcher != null )
		{
			this._domainDispatcher.addListener( this );
		}*/
	}
	
	public function dispatchDomainEvent( messageType : MessageType, data : Array<Dynamic> ) : Void
	{
		this._domainDispatcher.dispatch( messageType, data );
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
	
	public function sendMessageFromDomain( messageType : MessageType, data : Array<Dynamic> ) : Void
	{
		
	}
	
	public function addHandler( messageType : MessageType, scope : Dynamic, callback : Dynamic ) : Void
	{
		
	}
	
	public function removeHandler( messageType : MessageType, scope : Dynamic, callback : Dynamic ) : Void
	{
		
	}
	
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