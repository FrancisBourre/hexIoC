package hex.ioc.assembler;

import hex.di.IContextOwner;
import hex.di.IDependencyInjector;
import hex.error.IllegalArgumentException;
import hex.error.VirtualMethodException;
import hex.event.MessageType;
import hex.ioc.core.ICoreFactory;
import hex.log.Stringifier;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractApplicationContext implements Dynamic<AbstractApplicationContext> implements IContextOwner
{
	var _name 					: String;
	var _coreFactory 			: ICoreFactory;
	
	public function new( coreFactory : ICoreFactory, name : String ) 
	{
		this._coreFactory	= coreFactory;
		this._name			= name;
	}
	
	public function getName() : String
	{
		return this._name;
	}
	
	function resolve( field : String )
	{
		return this._coreFactory.locate( field );
	}

	public function addChild( applicationContext : AbstractApplicationContext ) : Bool
	{
		try
		{
			return this._coreFactory.register( applicationContext.getName(), applicationContext );
		}
		catch ( ex : IllegalArgumentException )
		{
			#if debug
			hex.log.Logger.ERROR( "addChild failed with applicationContext named '" + applicationContext.getName() + "'" );
			#end
			return false;
		}
	}

	public function dispatch( messageType : MessageType, ?data : Array<Dynamic> ) : Void
	{
		throw new VirtualMethodException( Stringifier.stringify( this ) + "._dispatch is not implemented" );
	}
	
	public function getCoreFactory() : ICoreFactory 
	{
		return this._coreFactory;
	}
	
	public function getInjector() : IDependencyInjector 
	{
		return this._coreFactory.getInjector();
	}
}