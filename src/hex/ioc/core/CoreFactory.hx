package hex.ioc.core;

import hex.collection.HashMap;
import hex.collection.ILocator;
import hex.collection.ILocatorListener;
import hex.collection.LocatorEvent;
import hex.core.IMetaDataParsable;
import hex.error.IllegalArgumentException;
import hex.error.NoSuchElementException;
import hex.event.EventDispatcher;
import hex.event.IEventDispatcher;
import hex.metadata.MetadataProvider;
import hex.service.IService;

/**
 * ...
 * @author Francis Bourre
 */
class CoreFactory implements ILocator<String, Dynamic>
{
	private var _hub : IEventDispatcher<ILocatorListener<String, Dynamic>, LocatorEvent<String, Dynamic>>;
	private var _map : HashMap<String, Dynamic>;

	public function new() 
	{
		this._hub = new EventDispatcher();
		this._map = new HashMap();
	}
	
	public function addListener( listener : ILocatorListener<String, Dynamic> ) : Bool
	{
		return this._hub.addListener( listener );
	}

	public function removeListener( listener : ILocatorListener<String, Dynamic> ) : Bool
	{
		return this._hub.removeListener( listener );
	}
	
	public function keys() : Array<String> 
	{
		return this._map.getKeys();
	}
	
	public function values() : Array<Dynamic> 
	{
		return this._map.getValues();
	}
	
	public function locate( key: String ) : Dynamic 
	{
		if ( this.isRegisteredWithKey( key ) )
        {
            return this._map.get( key );
        }
        else if ( key.indexOf(".") != -1 )
        {
            /*var props : Array<String> = key.split( "." );
			var baseKey : String = props.shift();
			if ( this.isRegisteredWithKey( baseKey ) )
			{
				var target : Dynamic = this._map.get( baseKey );
				return ObjectUtil.evalFromTarget( target, props.join("."), this );
			}*/
        }
		
		throw new NoSuchElementException( "Can't find item with '" + key + "' key in " + this );
	}
	
	public function isRegisteredWithKey( key : Dynamic ) : Bool 
	{
		return this._map.containsValue( key );
	}
	
	public function isInstanceRegistered( instance : Dynamic ) : Bool
	{
		return this._map.containsValue( instance ) ;
	}
	
	public function register( key : String, element : Dynamic ) : Bool 
	{
		if ( !this.isRegisteredWithKey( key ) )
		{
			this._map.put( key, element ) ;
			this._hub.dispatchEvent( new LocatorEvent( LocatorEvent.REGISTER, this, key, element ) ) ;
			return true ;
		}
		else
		{
			throw new IllegalArgumentException( "register(" + key + ", " + element + ") fails, key is already registered." );
		}
	}
	
	public function unregisterWithKey( key : String ) : Bool
	{
		if ( this.isRegisteredWithKey( key ) )
		{
			var instance : Dynamic = this._map.get( key );
			this._map.remove( key ) ;
			this._hub.dispatchEvent( new LocatorEvent( LocatorEvent.UNREGISTER, this, key, instance ) );
			return true ;
		}
		else
		{
			return false ;
		}
	}
	
	public function unregister( instance : Dynamic ) : Bool 
	{
		var key : String = this.getKeyOfInstance( instance );
		return ( key != null ) ? this.unregisterWithKey( key ) : false;
	}
	
	public function getKeyOfInstance( instance : Dynamic ) : String
	{
		var key : String;
		var isRegistered : Bool = this.isInstanceRegistered( instance );

		if ( isRegistered )
		{
			var keys : Array<String> = this._map.getKeys();
			for( key in keys )
			{
				if ( this.locate( key ) == instance ) 
				{
					return key;
				}
			}
		}

		return null;
	}
	
	public function add( map : Map<String, Dynamic> ) : Void 
	{
		var iterator = map.keys();

        while( iterator.hasNext() )
        {
            var key : String = iterator.next();
			try
			{
				this.register( key, map.get( key ) );
			}
			catch ( e : IllegalArgumentException )
			{
				e.message = this + ".add() fails. " + e.message;
				throw( e );
			}
        }
	}
	
	public function getClassReference( qualifiedClassName : String ) : Class<Dynamic>
	{
		var classReference : Class<Dynamic> = Type.resolveClass( qualifiedClassName );
		
		if ( classReference == null )
		{
			throw new IllegalArgumentException( this + ".getClassReference fails with class named '" + qualifiedClassName + "'" );
		}
		
		return classReference;
	}
	
	public function getStaticReference( qualifiedClassName : String ) : Dynamic
	{
		var a : Array<String> = qualifiedClassName.split( "." );
		var type : String = a[ a.length - 1 ];
		a.splice( a.length - 1, 1 );
		var classReference : Class<Dynamic>  = this.getClassReference( a.join( "." ) );
		var staticRef : Dynamic = Reflect.field( classReference, type );
		
		if ( staticRef == null )
		{
			throw new IllegalArgumentException( this + ".getStaticReference fails with '" + qualifiedClassName + "'" );
		}
		
		return staticRef;
	}
	
	public function buildInstance( qualifiedClassName : String, ?args : Array<Dynamic>, ?factoryMethod : String, ?singletonAccess : String ) : Dynamic
	{
		var classReference 	: Class<Dynamic>;

		try
		{
			classReference = this.getClassReference( qualifiedClassName );
		}
		catch ( e : IllegalArgumentException )
		{
			throw( "'" + qualifiedClassName + "' class is not available in current domain" );
		}

		var obj : Dynamic = null;

		if ( factoryMethod != null )
		{
			if ( singletonAccess != null )
			{
				var inst : Dynamic = null;

				var singletonCall : Dynamic = Reflect.field( classReference, singletonAccess );
				if ( singletonCall != null )
				{
					inst = singletonCall();
				}
				else
				{
					throw new IllegalArgumentException( qualifiedClassName + "." + singletonAccess + "()' singleton access failed." );
				}

				var methodReference : Dynamic = Reflect.field( inst, factoryMethod );
				if ( methodReference != null )
				{
					obj = Reflect.callMethod( inst, methodReference, args );
				}
				else 
				{
					throw new IllegalArgumentException( qualifiedClassName + "." + singletonAccess + "()." + factoryMethod + "()' factory method call failed." );
				}
			}
			else
			{
				var methodReference : Dynamic = Reflect.field( classReference, factoryMethod );
				
				if ( methodReference != null )
				{
					obj = Reflect.callMethod( classReference, methodReference, args );
				}
				else 
				{
					throw new IllegalArgumentException( qualifiedClassName + "." + factoryMethod + "()' factory method call failed." );
				}
			}

		} else if ( singletonAccess != null )
		{
			var singletonCall : Dynamic = Reflect.field( classReference, singletonAccess );
			if ( singletonCall != null )
			{
				obj = singletonCall();
			}
			else
			{
				throw new IllegalArgumentException( qualifiedClassName + "." + singletonAccess + "()' singleton call failed." );
			}
		}
		else
		{
			obj = Type.createInstance( classReference, args );

			if ( Std.is( obj, IMetaDataParsable ) )
			{
				MetadataProvider.getInstance().parse( obj );
			}

			if ( Std.is( obj, IService ) )
			{
				( cast obj ).createConfiguration();
			}
		}

		return obj;
	}
}