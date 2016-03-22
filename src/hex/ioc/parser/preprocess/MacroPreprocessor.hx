package hex.ioc.parser.preprocess;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author Francis Bourre
 */
class MacroPreprocessor
{
    function new()
    {

    }

    #if macro
    static public function parse( data : String, ?m : Expr  ) : String
	{
		if ( m != null )
		{
			var preprocessor = new Preprocessor();
			var props = new Map<String, String>();
			var key : String = null;
			var value : String = null;

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
								switch( e2.expr )
								{
									case EConst( c ):
										switch ( c )
										{
											case CString( s ):
												value = s;
											default:
										}
									default:
								}
							default:
						}

						if ( key != null && value != null )
						{
							props.set( key, value );
							preprocessor.addProperty( key, value );
						}
					}
					
					data = preprocessor.parse( data );

				default:
			}
		}
		
		return data;
	}
    #end
}