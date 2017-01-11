package hex.compiler.core;

import haxe.macro.Expr;
import hex.collection.ILocatorListener;
import hex.collection.LocatorMessage;
import hex.compiler.CompileTimeFastEval;
import hex.core.IAnnotationParsable;
import hex.di.IDependencyInjector;
import hex.error.IllegalArgumentException;
import hex.error.NoSuchElementException;
import hex.event.ClosureDispatcher;
import hex.event.MessageType;
import hex.core.ICoreFactory;
import hex.core.CoreFactoryVODef;
import hex.log.Stringifier;
import hex.metadata.IAnnotationProvider;
import hex.service.IService;
import hex.util.ClassUtil;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeCoreFactory implements ICoreFactory
{
	var _expressions 			: Array<Expr>;
	var _dispatcher 			: ClosureDispatcher;
	var _map 					: Map<String, {}>;

	static var _fastEvalMethod : Dynamic->String->ICoreFactory->Dynamic = CompileTimeFastEval.fromTarget;
	
	public function new( expressions : Array<Expr> ) 
	{
		this._expressions 			= expressions;
		this._dispatcher 			= new ClosureDispatcher();
		this._map 					= new Map();
	}
	
	public function getInjector() : IDependencyInjector 
	{
		return null;
	}
	
	public function getAnnotationProvider() : IAnnotationProvider
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
	
	public function buildInstance( constructorVO : CoreFactoryVODef ) : Dynamic
	{
		return null;
	}
	
	public function addProxyFactoryMethod( className : String, socpe : Dynamic, factoryMethod : Dynamic ) : Void
	{
		//
	}
	
	public function removeProxyFactoryMethod( classPath : String ) : Bool
	{
		return false;
	}
	
	public function hasProxyFactoryMethod( className : String ) : Bool
	{
		return false;
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