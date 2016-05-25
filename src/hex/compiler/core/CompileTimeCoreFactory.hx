package hex.compiler.core;

import haxe.macro.Expr;
import hex.collection.ILocatorListener;
import hex.collection.LocatorMessage;
import hex.compiler.CompileTimeFastEval;
import hex.core.IAnnotationParsable;
import hex.di.IDependencyInjector;
import hex.error.IllegalArgumentException;
import hex.error.NoSuchElementException;
import hex.event.Dispatcher;
import hex.event.IDispatcher;
import hex.ioc.core.ICoreFactory;
import hex.log.Stringifier;
import hex.service.IService;
import hex.util.ClassUtil;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeCoreFactory implements ICoreFactory
{
	var _expressions 			: Array<Expr>;
	var _dispatcher 			: IDispatcher<ILocatorListener<String, Dynamic>>;
	var _map 					: Map<String, {}>;

	static var _fastEvalMethod : Dynamic->String->ICoreFactory->Dynamic = CompileTimeFastEval.fromTarget;
	
	public function new( expressions : Array<Expr> ) 
	{
		this._expressions 			= expressions;
		this._dispatcher 			= new Dispatcher<ILocatorListener<String, Dynamic>>();
		this._map 					= new Map();
	}
	
	public function getBasicInjector() : IDependencyInjector 
	{
		return null;
	}
	
	public function clear() : Void 
	{
		this._map = new Map();
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
	
	public function isRegisteredWithKey( key : Dynamic ) : Bool 
	{
		return this._map.exists( key );
	}
	
	public function isInstanceRegistered( instance : Dynamic ) : Bool
	{
		return this.values().indexOf( instance ) != -1;
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
		
		throw new NoSuchElementException( "Can't find item with '" + key + "' key in " + Stringifier.stringify(this) );
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
			throw new IllegalArgumentException( "register(" + key + ", " + element + ") fails, key is already registered." );
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
				e.message = this + ".add() fails. " + e.message;
				throw( e );
			}
        }
	}
	
	public function addListener( listener : ILocatorListener<String, Dynamic> ) : Bool
	{
		return this._dispatcher.addListener( listener );
	}

	public function removeListener( listener : ILocatorListener<String, Dynamic> ) : Bool
	{
		return this._dispatcher.removeListener( listener );
	}
	
	public function buildInstance( qualifiedClassName : String, ?args : Array<Dynamic>, ?factoryMethod : String, ?singletonAccess : String, ?instantiateUnmapped : Bool = false ) : Dynamic
	{
		var classReference 	: Class<Dynamic>;

		try
		{
			classReference = ClassUtil.getClassReference( qualifiedClassName );
		}
		catch ( e : IllegalArgumentException )
		{
			throw new IllegalArgumentException( "'" + qualifiedClassName + "' class is not available in current domain" );
		}

		var obj : Dynamic = null;
		
		if ( instantiateUnmapped )
		{
//			obj = this._injector.instantiateUnmapped( classReference );
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
			try
			{
				obj = Type.createInstance( classReference, args != null ? args : [] );
			}
			catch ( e : Dynamic )
			{
				throw new IllegalArgumentException( "Instantiation of class '" + qualifiedClassName + "' failed with arguments: " + args + " : " + e);
			}

			if ( Std.is( obj, IAnnotationParsable ) )
			{
//				this._annotationProvider.parse( obj );
			}

			if ( Std.is( obj, IService ) )
			{
				( cast obj ).createConfiguration();
			}
		}

		return obj;
	}
	
	public function fastEvalFromTarget( target : Dynamic, toEval : String ) : Dynamic
	{
		return CompileTimeCoreFactory._fastEvalMethod( target, toEval, this );
	}
	
	static public function setFastEvalMethod( method : Dynamic->String->ICoreFactory->Dynamic ) : Void
	{
		CompileTimeCoreFactory._fastEvalMethod = method;
	}
}