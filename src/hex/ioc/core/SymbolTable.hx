package hex.ioc.core;

import hex.error.IllegalArgumentException;

/**
 * ...
 * @author Francis Bourre
 */
class SymbolTable
{
	var _map : Map<String, Bool>;

	public function new()
	{
		this._map = new Map<String, Bool>();
	}

	public function isRegistered( id : String ) : Bool
	{
		return this._map.exists( id );
	}

	public function clear() : Void
	{
		this._map = new Map<String, Bool>();
	}

	public function register( id : String ) : Bool
	{
		if ( this._map.exists( id ) )
		{
			throw new IllegalArgumentException( this + ".register(" + id + ") failed. This id was already registered, check conflicts in your config file." );

		} else
		{
			this._map.set( id, true );
			return true;
		}

		return false;
	}

	public function unregister( id : String ) : Bool
	{
		if ( this.isRegistered( id ) )
		{
			this._map.remove( id );
			return true;
		}
		else
		{
			throw new IllegalArgumentException( this + ".unregister(" + id + ") failed." );
		}

		return false;
	}
}