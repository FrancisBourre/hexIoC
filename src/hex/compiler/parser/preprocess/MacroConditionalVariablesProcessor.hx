package hex.compiler.parser.preprocess;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author Francis Bourre
 */
class MacroConditionalVariablesProcessor
{
	function new() 
	{
		
	}
	
	#if macro
    static public function parse( m : Expr  )
	{
		var props = new Map<String, Bool>();
		
		if ( m != null )
		{
			var key : String = null;
			var value : Bool = null;

			switch ( m.expr )
			{
				case EArrayDecl( exprs ):
					for ( e in exprs )
					{
						switch( e.expr )
						{
							case EBinop( op, e1, e2 ):
								switch( e1.expr )
								{
									case EConst( c ):
										switch ( c )
										{
											case CString( s ):
												key = s;
											default:
										}
									default:
								}
								
								value = switch( e2.expr )
								{
									case EConst( c ):
										switch ( c )
										{
											case CInt( i ):
												Std.parseInt( i ) == 0 ? false : true;

											case CIdent( "true" ):
												true;
											
											case CIdent("false"):
												false;
												
											default:
												null;
										}
									default:
										null;
								}
							default:
						}

						if ( key != null && value != null )
						{
							props.set( key, value );
						}
					}

				default:
			}
		}
		
		var defines : Map<String,String> = Context.getDefines();
		for ( key in defines.keys() ) 
		{
			var value = defines.get( key );
			if( "" + value == 'true' || "" + value == 'false' )
			{
				var b = value =='true' ? true : false;

				if ( props.exists( key ) )
				{
					if ( props.get( key ) != b )
					{
						Context.error( "'" + key + "' key is defined twice with different values.", Context.currentPos() );
					}
					else
					{
						Context.error( "'" + key + "' key is defined twice.", Context.currentPos() );
					}
				}
				else
				{
					props.set( key, b );
				}
			}
    	}

		return props;
	}
    #end
}