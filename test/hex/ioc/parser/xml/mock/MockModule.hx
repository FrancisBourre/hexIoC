package hex.ioc.parser.xml.mock;

import hex.core.IApplicationContext;
import hex.di.IDependencyInjector;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.domain.DomainExpert;
import hex.event.IDispatcher;
import hex.event.MessageType;
import hex.log.ILogger;
import hex.module.IModule;

/**
 * ...
 * @author Francis Bourre
 */
class MockModule implements IModule
{
	var _domainDispatcher 	: IDispatcher<{}>;
	
	public function new( context : IApplicationContext ) 
	{
		this._domainDispatcher = ApplicationDomainDispatcher.getInstance( context ).getDomainDispatcher( this.getDomain() );
	}
	
	public function dispatchDomainEvent( messageType : MessageType, data : Array<Dynamic> ) : Void
	{
		this._domainDispatcher.dispatch( messageType, data );
	}
	
	public function getDomain() : Domain
	{
		return DomainExpert.getInstance().getDomainFor( this );
	}
	
	public function initialize( context : IApplicationContext ) : Void 
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
	
	public function dispatchPublicMessage( messageType : MessageType, ?data : Array<Dynamic> ) : Void
	{
		
	}
	
	public function addHandler( messageType : MessageType, scope : Dynamic, callback : haxe.Constraints.Function ) : Void
	{
		
	}
	
	public function removeHandler( messageType : MessageType, scope : Dynamic, callback : haxe.Constraints.Function ) : Void
	{
		
	}
	
	public function getInjector() : IDependencyInjector
	{
		return null;
	}
	
	public function getLogger() : ILogger
	{
		return null;
	}
}