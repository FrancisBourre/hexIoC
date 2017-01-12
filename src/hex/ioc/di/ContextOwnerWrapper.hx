package hex.ioc.di;

import hex.di.IContextOwner;
import hex.di.IDependencyInjector;
import hex.core.ICoreFactory;

/**
 * ...
 * @author Francis Bourre
 */
class ContextOwnerWrapper implements IContextOwner
{
	var _coreFactory 	: ICoreFactory;
	var _id 			: String;
	
	public function new( coreFactory : ICoreFactory, id : String ) 
	{
		this._coreFactory 	= coreFactory;
		this._id 			= id;
	}
	
	public function getInjector() : IDependencyInjector 
	{
		return ( cast this._coreFactory.locate( this._id ) ).getInjector();
	}
}