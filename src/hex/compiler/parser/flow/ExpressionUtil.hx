package hex.compiler.parser.flow;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import hex.error.PrivateConstructorException;
import hex.ioc.core.ContextTypeList;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.MapVO;
import hex.ioc.vo.PropertyVO;

/**
 * ...
 * @author Francis Bourre
 */
@:final
class ExpressionUtil 
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }

	static public function compressField( e : ExprDef, ?previousValue : String = "" ) : String
	{
		return switch( e )
		{
			case EField( ee, field ):
				previousValue = previousValue == "" ? field : field + "." + previousValue;
				return compressField( ee.expr, previousValue );
				
			case EConst( CIdent( id ) ):
				return previousValue == "" ? id : id + "." + previousValue;

			default:
				return previousValue;
		}
	}
	
	static public function getArgument( id : String, e : Expr ) : ConstructorVO
	{
		var vo : ConstructorVO;

		switch( e.expr )
		{
			case EConst(CString(v)):
				//String
				vo = new ConstructorVO( id, ContextTypeList.STRING, [ v ] );

			case EConst(CInt(v)):
				//Int
				vo = new ConstructorVO( id, ContextTypeList.INT, [ v ] );

			case EConst(CFloat(v)):
				//Float
				vo = new ConstructorVO( id, ContextTypeList.FLOAT, [ v ] );

			case EConst(CIdent(v)):
				
				var args : Array<Dynamic>;

				switch( v )
				{
					case "null":
						//null
						vo =  new ConstructorVO( id, ContextTypeList.NULL, [ 'null' ] );

					case "true" | "false":
						//Boolean
						vo =  new ConstructorVO( id, ContextTypeList.BOOLEAN, [ v ] );

					case _:
						//Object reference
						vo =  new ConstructorVO( id, ContextTypeList.INSTANCE, [ v ], null, null, null, v );
				}

			case EField( e, field ):
				//Property or method reference
				vo =  new ConstructorVO( id, ContextTypeList.INSTANCE, [], null, null, null, compressField(e.expr) + '.' + field );

			case _:
				trace( e.expr );
		}

		vo.filePosition = e.pos;
		return vo;
	}
	
	static public function getProperty( ident : String, field : String, assigned : Expr ) : PropertyVO
	{
		var propertyVO 	: PropertyVO;
		var type 		: String;
		var ref 		: String;
		
		switch( assigned.expr )
		{
			case EConst(CIdent(v)):
				
				switch( v )
				{
					case "null":
						type = ContextTypeList.NULL;
						propertyVO = new PropertyVO( ident, field, v, type, ref );
						
					case "true" | "false":
						type = ContextTypeList.BOOLEAN;
						propertyVO = new PropertyVO( ident, field, v, type, ref );
						
					case _:
						type = ContextTypeList.INSTANCE;
						ref = v;
						v = null;
						propertyVO = new PropertyVO( ident, field, v, type, ref );
				}
			
			case EConst(CInt(v)):
				//Int
				propertyVO = new PropertyVO( ident, field, v, ContextTypeList.INT );
				
			case EConst(CFloat(v)):
				//Float
				propertyVO = new PropertyVO( ident, field, v, ContextTypeList.FLOAT );
				
			case EConst(CString(v)):
				//String
				propertyVO = new PropertyVO( ident, field, v, ContextTypeList.STRING );
				
			case EField( e, ff ):
				
				var className = ExpressionUtil.compressField( e.expr, ff );
				var exp = Context.parse( '(null: ${className})', Context.currentPos() );

				switch( exp.expr )
				{
					case EParenthesis( _.expr => ECheckType( ee, TPath(p) ) ):
						
						if ( p.sub != null )
						{
							propertyVO = new PropertyVO( ident, field, null, null, null, null, className );
						}
						else
						{
							propertyVO = new PropertyVO( ident, field, className, ContextTypeList.CLASS, null, null, null );
						}
						
					case _:
						
						trace( exp );
				}
				
			case _:
				trace( assigned.expr );
		}
			
		propertyVO.filePosition = assigned.pos;
		return propertyVO;
	}
	
	static public function getMapArguments( ident : String, params : Array<Expr> ) : Array<MapVO>
	{
		var args : Array<MapVO> = [];
		
		var it = params.iterator();
		while ( it.hasNext() )
		{
			var param = it.next();
			
			switch( param.expr )
			{
				case EBinop( OpArrow, e1, e2 ):
					
					var key 	= ExpressionUtil.getArgument( ident, e1 );
					var value 	= ExpressionUtil.getArgument( ident, e2 );
					var mapVO 	= new MapVO( key, value );
					mapVO.filePosition = param.pos;
					args.push( mapVO );
					
				case _:
					
					trace( param.expr );
			}
			
		}
		
		return args;
	}
	
	static public function getFullClassDeclaration( tp : TypePath ) : String
	{
		var className = ExprTools.toString( macro new $tp() );
		return className.split( "new " ).join( '' ).split( '()' ).join( '' );
	}
}