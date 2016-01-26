package hex.ioc.di;

import hex.di.IBasicInjector;
import hex.di.IContextOwner;
import hex.ioc.core.CoreFactory;

/**
 * ...
 * @author Francis Bourre
 */
class ContextOwnerWrapper implements IContextOwner
{
	var _coreFactory 	: CoreFactory;
	var _id 			: String;
	
	public function new( coreFactory : CoreFactory, id : String ) 
	{
		this._coreFactory 	= coreFactory;
		this._id 			= id;
	}
	
	public function getBasicInjector() : IBasicInjector 
	{
		return ( cast this._coreFactory.locate( this._id ) ).getBasicInjector();
	}
}