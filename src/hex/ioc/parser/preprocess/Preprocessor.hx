package hex.ioc.parser.preprocess;

import hex.error.IllegalArgumentException;
import hex.data.IParser;

class Preprocessor implements IParser
{
	var _property 	: Map<String, String>;
	var _separator 	: EReg = ~/\$\{.*\}/;

	public function new()
	{
		this._property = new Map();
	}

	public function addProperty( name : String, value : String ) : Void
	{
		if ( !this._property.exists( name ) )
		{
			this._property.set( name, value );
		}
		else
		{
			throw new IllegalArgumentException( "addProperty failed with property name '" + name + "' and value '" + value + "'. This name is already registered." );
		}
	}

	public function parse( serializedContetnt : Dynamic, target : Dynamic = null ) : Dynamic
	{
		var context : String = cast serializedContetnt;

		var i = this._property.keys();
		while( i.hasNext() )
		{
			var name : String = i.next();
			var value : String = this._property.get( name );
			
			var a = context.split( '$' + '{' + name + "}" );
			if ( a.length > 1 )
			{
				for ( element in a )
				{
					this.parse( element );
				}
			}
			
			context = a.join( value );
		}
		
		if ( this._separator.match( context ) )
		{
			return this.parse( context );
		}
		else
		{
			return context;
		}
	}
}