package hex.ioc.assembler;

import hex.core.IApplicationContext;
import hex.di.IDependencyInjector;
import hex.domain.Domain;
import hex.domain.DomainUtil;
import hex.error.VirtualMethodException;
import hex.event.MessageType;
import hex.core.ICoreFactory;
import hex.log.Stringifier;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractApplicationContext implements IApplicationContext
{
	var _name 					: String;
	var _coreFactory 			: ICoreFactory;
	var _domain 				: Domain;
	
	public function new( coreFactory : ICoreFactory, name : String ) 
	{
		this._coreFactory	= coreFactory;
		this._name			= name;
		this._domain		= DomainUtil.getDomain( name, Domain );
	}
	
	public function getName() : String
	{
		return this._name;
	}
	
	public function getDomain() : Domain
	{
		return this._domain;
	}

	public function dispatch( messageType : MessageType, ?data : Array<Dynamic> ) : Void
	{
		throw new VirtualMethodException( Stringifier.stringify( this ) + ".dispatch is not implemented" );
	}
	
	public function getCoreFactory() : ICoreFactory 
	{
		return this._coreFactory;
	}
	
	public function getInjector() : IDependencyInjector 
	{
		return this._coreFactory.getInjector();
	}
	
	public function dispose() : Void
	{
		//
	}
}