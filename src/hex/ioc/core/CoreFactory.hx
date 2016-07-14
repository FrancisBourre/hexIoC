package hex.ioc.core;

import hex.collection.ILocatorListener;
import hex.collection.LocatorMessage;
import hex.core.IAnnotationParsable;
import hex.di.IDependencyInjector;
import hex.error.IllegalArgumentException;
import hex.error.NoSuchElementException;
import hex.event.Dispatcher;
import hex.event.IDispatcher;
import hex.log.Stringifier;
import hex.metadata.IAnnotationProvider;
import hex.service.IService;
import hex.util.ClassUtil;
import hex.util.FastEval;

/**
 * ...
 * @author Francis Bourre
 */
class CoreFactory implements ICoreFactory
{
	var _injector 				: IDependencyInjector;
	var _annotationProvider 	: IAnnotationProvider;
	var _dispatcher 			: IDispatcher<ILocatorListener<String, Dynamic>>;
	var _map 					: Map<String, {}>;
	var _classPaths 			: Map<String, ProxyFactoryMethodHelper>;
	
	static var _fastEvalMethod : Dynamic->String->ICoreFactory->Dynamic = FastEval.fromTarget;
	
	public function new( injector : IDependencyInjector, annotationProvider : IAnnotationProvider ) 
	{
		this._injector 				= injector;
		this._annotationProvider 	= annotationProvider;
		this._dispatcher 			= new Dispatcher<ILocatorListener<String, Dynamic>>();
		this._map 					= new Map();
		this._classPaths 			= new Map();
	}
	
	public function getAnnotationProvider() : IAnnotationProvider 
	{
		return this._annotationProvider;
	}
	
	public function addListener( listener : ILocatorListener<String, Dynamic> ) : Bool
	{
		return this._dispatcher.addListener( listener );
	}

	public function removeListener( listener : ILocatorListener<String, Dynamic> ) : Bool
	{
		return this._dispatcher.removeListener( listener );
	}
	
	public function keys() : Array<String> 
	{
		var a = [];
		var it = this._map.keys();
		while ( it.hasNext() ) a.push( it.next() );
		return a;
	}
	
	public function values() : Array<Dynamic> 
	{
		var a = [];
		var it = this._map.iterator();
		while ( it.hasNext() ) a.push( it.next() );
		return a;
	}
	
	public function locate( key: String ) : Dynamic 
	{
		if ( this._map.exists( key ) )
        {
            return this._map.get( key );
        }
        else if ( key.indexOf(".") != -1 )
        {
            var props : Array<String> = key.split( "." );
			var baseKey : String = props.shift();
			if ( this._map.exists( baseKey ) )
			{
				var target : Dynamic = this._map.get( baseKey );
				return this.fastEvalFromTarget( target, props.join(".") );
			}
        }
		
		throw new NoSuchElementException( "Can't find item with '" + key + "' key in " + Stringifier.stringify( this ) );
	}
	
	public function isRegisteredWithKey( key : Dynamic ) : Bool 
	{
		return this._map.exists( key );
	}
	
	public function isInstanceRegistered( instance : Dynamic ) : Bool
	{
		return this.values().indexOf( instance ) != -1;
	}
	
	public function register( key : String, element : Dynamic ) : Bool 
	{
		if ( !this._map.exists( key ) )
		{
			this._map.set( key, element ) ;
			this._dispatcher.dispatch( LocatorMessage.REGISTER, [ key, element ] ) ;
			return true ;
		}
		else
		{
			throw new IllegalArgumentException( "register fails, key is already registered." );
		}
	}
	
	public function unregisterWithKey( key : String ) : Bool
	{
		if ( this._map.exists( key ) )
		{
			var instance : Dynamic = this._map.get( key );
			this._map.remove( key ) ;
			this._dispatcher.dispatch( LocatorMessage.UNREGISTER, [ key ] ) ;
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
		var iterator = this._map.keys();
		while( iterator.hasNext() )
		{
			var key = iterator.next();
			if ( this._map.get( key ) == instance ) 
			{
				return key;
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
				e.message = "add() fails. " + e.message;
				throw( e );
			}
        }
	}
	
	public function buildInstance( qualifiedClassName : String, ?args : Array<Dynamic>, ?factoryMethod : String, ?singletonAccess : String, ?instantiateUnmapped : Bool = false ) : Dynamic
	{
		var classReference 	: Class<Dynamic> 			= null;
		var classFactory 	: ProxyFactoryMethodHelper 	= null;

		//TODO Optimize and make unit tests
		if ( this._classPaths.exists( qualifiedClassName ) )
		{
			classFactory = this._classPaths.get( qualifiedClassName );
		}
		else
		{
			try
			{
				classReference = ClassUtil.getClassReference( qualifiedClassName );
			}
			catch ( e : IllegalArgumentException )
			{
				throw new IllegalArgumentException( "'" + qualifiedClassName + "' class is not available in current domain" );
			}
		}

		var obj : Dynamic = null;
		
		if ( instantiateUnmapped )
		{
			obj = this._injector.instantiateUnmapped( classReference );
		}
		else if ( factoryMethod != null )
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
			if ( args == null )
			{
				args = [];
			}
			
			if ( classReference != null )
			{
				try
				{
					obj = Type.createInstance( classReference, args );
				}
				catch ( e : Dynamic )
				{
					throw new IllegalArgumentException( "Instantiation of class '" + qualifiedClassName + "' failed with arguments: " + args + " : " + e );
				}
			}
			else
			{
				try
				{
					obj = Reflect.callMethod( classFactory.scope, classFactory.factoryMethod, args );

				}
				catch ( e : Dynamic )
				{
					throw new IllegalArgumentException( "Instantiation of class '" + qualifiedClassName + "' failed with class factory and arguments: " + args + " : " + e );
				}
			}

			if ( Std.is( obj, IAnnotationParsable ) )
			{
				this._annotationProvider.parse( obj );
			}

			if ( Std.is( obj, IService ) )
			{
				( cast obj ).createConfiguration();
			}
		}

		return obj;
	}
	
	public function clear() : Void
	{
		this._map 			= new Map();
		this._classPaths 	= new Map();
	}
	
	public function getInjector() : IDependencyInjector
	{
		return this._injector;
	}
	
	public function addProxyFactoryMethod( classPath : String, scope : Dynamic, factoryMethod : Dynamic ) : Void
	{
		//TODO secure with type parameter
		if ( !this._classPaths.exists( classPath ) )
		{
			this._classPaths.set( classPath, {scope:scope, factoryMethod:factoryMethod} );
		}
		else
		{
			throw new IllegalArgumentException( "registerClassPath(" + classPath + ", " + factoryMethod + ") fails, classPath is already registered." );
		}
	}
	
	public function removeProxyFactoryMethod( classPath : String ) : Bool
	{
		if ( this._classPaths.exists( classPath ) )
		{
			this._classPaths.remove( classPath );
			return true;
		}
		else
		{
			return false;
		}
	}
	
	public function hasProxyFactoryMethod( className : String ) : Bool
	{
		return this._classPaths.exists( className );
	}
	
	public function fastEvalFromTarget( target : Dynamic, toEval : String ) : Dynamic
	{
		return CoreFactory._fastEvalMethod( target, toEval, this );
	}
	
	static public function setFastEvalMethod( method : Dynamic->String->ICoreFactory->Dynamic ) : Void
	{
		CoreFactory._fastEvalMethod = method;
	}
}

typedef ProxyFactoryMethodHelper =
{
	scope : Dynamic,
	factoryMethod : Dynamic
}