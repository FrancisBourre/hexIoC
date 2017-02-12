package hex.ioc.core;

import hex.collection.ILocatorListener;
import hex.collection.LocatorMessage;
import hex.core.CoreFactoryVODef;
import hex.core.IAnnotationParsable;
import hex.di.IDependencyInjector;
import hex.error.IllegalArgumentException;
import hex.error.NoSuchElementException;
import hex.event.ClosureDispatcher;
import hex.event.MessageType;
import hex.log.Stringifier;
import hex.metadata.IAnnotationProvider;
import hex.runtime.basic.IRunTimeCoreFactory;
import hex.service.IService;
import hex.util.ClassUtil;
import hex.util.FastEval;

/**
 * ...
 * @author Francis Bourre
 */
class CoreFactory implements IRunTimeCoreFactory
{
	var _injector 				: IDependencyInjector;
	var _annotationProvider 	: IAnnotationProvider;
	var _dispatcher 			: ClosureDispatcher;
	var _map 					: Map<String, {}>;
	var _classPaths 			: Map<String, ProxyFactoryMethodHelper>;
	
	static var _fastEvalMethod : Dynamic->String->IRunTimeCoreFactory->Dynamic = FastEval.fromTarget;
	
	public function new( injector : IDependencyInjector, annotationProvider : IAnnotationProvider ) 
	{
		this._injector 				= injector;
		this._annotationProvider 	= annotationProvider;
		this._dispatcher 			= new ClosureDispatcher();
		this._map 					= new Map();
		this._classPaths 			= new Map();
		
		this.addProxyFactoryMethod( 'hex.event.MessageType', this, this._makeMessageType );
	}
	
	function _makeMessageType( s : String ) : String
	{
		return s;
	}
	
	public function addHandler( messageType : MessageType, callback : Dynamic ) : Bool
	{
		return this._dispatcher.addHandler( messageType, callback );
	}
	
	public function removeHandler( messageType : MessageType, callback : Dynamic ) : Bool
	{
		return this._dispatcher.removeHandler( messageType, callback );
	}
	
	public function addListener( listener : ILocatorListener<String, Dynamic> ) : Bool
    {
		var b = this._dispatcher.addHandler( LocatorMessage.REGISTER, listener.onRegister );
		return this._dispatcher.addHandler( LocatorMessage.UNREGISTER, listener.onUnregister ) || b;
    }

    public function removeListener( listener : ILocatorListener<String, Dynamic> ) : Bool
    {
		var b = this._dispatcher.removeHandler( LocatorMessage.REGISTER, listener.onRegister );
		return this._dispatcher.removeHandler( LocatorMessage.UNREGISTER, listener.onUnregister ) || b;
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
	
	public function buildInstance( constructorVO : CoreFactoryVODef ) : Dynamic
	{
		var qualifiedClassName 	= constructorVO.className;
		var args 				= constructorVO.arguments;
		var factoryMethod 		= constructorVO.factory;
		var staticCall 			= constructorVO.staticCall;
		var staticRef 			= constructorVO.staticRef;
		var injectorCreation 	= constructorVO.injectorCreation;
		var injectInto 			= constructorVO.injectInto;
		
		var classReference 	: Class<Dynamic> 			= null;
		var classFactory 	: ProxyFactoryMethodHelper 	= null;

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
		
		if ( injectorCreation )
		{
			obj = this._injector.instantiateUnmapped( classReference );
		}
		else if ( factoryMethod != null )//factory method
		{
			if ( staticRef != null )//static variable - with factory method
			{
				var staticReference = Reflect.field( classReference, staticRef );
				
				if ( staticReference != null )
				{
					#if flash
					obj = Reflect.callMethod( Reflect.field( classReference, staticRef ), Reflect.field( Reflect.field( classReference, staticRef ), factoryMethod ), args );
					#else
					var methodReference = Reflect.field( staticReference, factoryMethod );
					
					if ( methodReference != null )
					{
						obj = Reflect.callMethod( staticReference, methodReference, args );
					}
					else
					{
						throw new IllegalArgumentException( qualifiedClassName + "." + staticReference + "." + factoryMethod + "()' factory method call failed." );
					}
					#end
				}
				else 
				{
					throw new IllegalArgumentException( qualifiedClassName + "." + staticReference + "' is not available." );
				}
			}
			else if ( staticCall != null )//static method call - with factory method
			{
				var inst : Dynamic = null;

				var staticCallRef = Reflect.field( classReference, staticCall );
				if ( staticCallRef != null )
				{
					inst = staticCallRef();
				}
				else
				{
					throw new IllegalArgumentException( qualifiedClassName + "." + staticCall + "()' static method call failed." );
				}

				var methodReference : Dynamic = Reflect.field( inst, factoryMethod );
				if ( methodReference != null )
				{
					obj = Reflect.callMethod( inst, methodReference, args );
				}
				else 
				{
					throw new IllegalArgumentException( qualifiedClassName + "." + staticCall + "()." + factoryMethod + "()' factory method call failed." );
				}
			}
			else
			{
				throw new IllegalArgumentException( "'" + factoryMethod + "' method cannot be called on '" + 
					constructorVO.className +"' class. Add static method or variable to make it working." );
			}
			
		} else if ( staticCall != null )//simple static method call
		{
			var staticCallReference = Reflect.field( classReference, staticCall );
			if ( staticCallReference != null )
			{
				obj = Reflect.callMethod( classReference, staticCallReference, args );//staticCallReference( args );
			}
			else
			{
				throw new IllegalArgumentException( qualifiedClassName + "." + staticCall + "()' static method call failed." );
			}
		}
		else//Standard instantiation
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
			
			if ( injectInto )
			{
				this._injector.injectInto( obj );
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
	
	static public function setFastEvalMethod( method : Dynamic->String->IRunTimeCoreFactory->Dynamic ) : Void
	{
		CoreFactory._fastEvalMethod = method;
	}
}

typedef ProxyFactoryMethodHelper =
{
	scope : Dynamic,
	factoryMethod : Dynamic
}