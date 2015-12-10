package hex.ioc.locator;

import hex.collection.Locator;
import hex.collection.LocatorEvent;
import hex.domain.Domain;
import hex.event.EventProxy;
import hex.event.IAdapterStrategy;
import hex.event.CallbackAdapter;
import hex.ioc.core.BuilderFactory;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.module.IModule;
import hex.service.IService;
import hex.service.Service;

/**
 * ...
 * @author Francis Bourre
 */
class DomainListenerVOLocator extends Locator<String, DomainListenerVO, LocatorEvent<String, DomainListenerVO>>
{
	private var _builderFactory : BuilderFactory;

	public function new( builderFactory : BuilderFactory )
	{
		super();
		this._builderFactory = builderFactory;
	}
	
	public function assignAllDomainListeners() : Void
	{
		var listeners : Array<String> = this.keys();
		for ( key in listeners )
		{
			this.assignDomainListener( key );
		}
		
		this.clear();
	}

	public function assignDomainListener( id : String ) : Bool
	{
		var domainListener : DomainListenerVO 			= this.locate( id );
		var listener : Dynamic 							= this._builderFactory.getCoreFactory().locate( domainListener.ownerID );
		var args : Array<DomainListenerVOArguments> 	= domainListener.arguments;

		// Check if event provider is a service
		var service : Service = null;
		if ( this._builderFactory.getCoreFactory().isRegisteredWithKey( domainListener.listenedDomainName ) )
		{
			var located : Dynamic = this._builderFactory.getCoreFactory().locate( domainListener.listenedDomainName );
			if ( Std.is( located, IService ) )
			{
				service = cast located;
			}
		}

		if ( args != null && args.length > 0 )
		{
			for ( domainListenerArgument in args )
			{
				var method : String = Std.is( listener, EventProxy ) ? "handleEvent" : domainListenerArgument.method;
				var noteType : String = domainListenerArgument.name != null ? domainListenerArgument.name : this._builderFactory.getCoreFactory().getStaticReference( domainListenerArgument.staticRef );

				//if ( method != null && listener.hasOwnProperty( method ) && listener[ method ] is Function )
				if ( method != null && Reflect.hasField( listener, method ) &&  Reflect.isFunction( Reflect.field( listener, method ) ) )
				{
					var callback : Dynamic = domainListenerArgument.strategy != null ? this.getStrategyCallback( listener, method, domainListenerArgument.strategy, domainListenerArgument.injectedInModule ) : Reflect.field( listener, method );

					if ( service == null )
					{
						this._builderFactory.getApplicationHub().addEventListener( noteType, callback, new Domain( domainListener.listenedDomainName ) );
					}
					else
					{
						service.addHandler( noteType, callback );
					}
				}
			}

			return true;

		} else
		{
			return this._builderFactory.getApplicationHub().addListener( listener, new Domain( domainListener.listenedDomainName ) );
		}
	}

	private function getStrategyCallback( listener : Dynamic, method : String, strategyClassName : String, injectedInModule : Bool = false ) : Dynamic
	{
		/*var callback : Dynamic 								= Reflect.field( listener, method );
		var strategyClass : Class<IEventAdapterStrategy> 	= cast this._builderFactory.getCoreFactory().getClassReference( strategyClassName );
		var adapter : CallbackAdapter 							= new CallbackAdapter ( 	callback, strategyClass,
																( ( injectedInModule && Std.is( listener, IModule ) ) ? 
																( cast listener ).instantiateUnmapped  :  
																this._builderFactory.getApplicationContext().getInjector().instantiateUnmapped )
															);
		return adapter.getCallbackAdapter();*/
		return null;
	}
	
	override function _dispatchRegisterEvent( key : String, element : DomainListenerVO ) : Void 
	{
		this._dispatcher.dispatchEvent( new LocatorEvent( LocatorEvent.REGISTER, this, key, element ) );
	}
	
	override function _dispatchUnregisterEvent( key : String ) : Void 
	{
		this._dispatcher.dispatchEvent( new LocatorEvent( LocatorEvent.UNREGISTER, this, key ) );
	}
}
	/**
	 protected function getStrategyCallback( listener : Object, method : String, strategyClassName : String, injectedInModule : Boolean = false ) : Function
	{
		var callback : Function 			= listener[ method ];
		var strategyClassReference : Class 	= this._builderFactory.getCoreFactory().getClassReference( strategyClassName );
		var adapter : IOAdapter 			= new IOAdapter ( 	callback, strategyClassReference,
																( ( injectedInModule && listener is BaseModule ) ? ( listener as BaseModule ).instantiateUnmapped  :  this._builderFactory.getApplicationContext().getInjector().instantiateUnmapped )
															);
		return adapter.getCallbackAdapter();
	}**/