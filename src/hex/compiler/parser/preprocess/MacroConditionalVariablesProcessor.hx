package hex.compiler.parser.preprocess;

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
								switch( e2.expr )
								{
									case EConst( c ):
										switch ( c )
										{
											case CIdent( "true" ):
												value = true;

											case CIdent("false"):
												value = false;
												
											default:
										}
									default:
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
		
		return props;
	}
    #end
}