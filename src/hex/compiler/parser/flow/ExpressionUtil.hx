package hex.compiler.parser.flow;

import haxe.macro.Expr;
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
		var type 	: String;
		var ref 	: String;
		var vo 		: ConstructorVO;
		
		switch( e.expr )
		{
			case EConst(CString(v)):
				type = ContextTypeList.STRING;
				vo = new ConstructorVO( id, type, [ v ] );
				
			
			case EConst(CInt(v)):
				type = ContextTypeList.INT;
				vo = new ConstructorVO( id, type, [ v ] );
				
			case EConst(CFloat(v)):
				type = ContextTypeList.FLOAT;
				vo = new ConstructorVO( id, type, [ v ] );
				
			case EConst(CIdent(v)):
				var args : Array<Dynamic>;
				
				switch( v )
				{
					case "null":
						type = ContextTypeList.NULL;
						args = [ v ];
						
					case "true" | "false":
						type = ContextTypeList.BOOLEAN;
						args = [ v ];
						
					case _:
						type = ContextTypeList.INSTANCE;
						ref = v;
				}
				
				vo =  new ConstructorVO( id, type, args, null, null, null, ref );
			
			case EField( e, field ):
				type = ContextTypeList.INSTANCE;
				ref = compressField(e.expr) + '.' + field;
				vo =  new ConstructorVO( id, type, [], null, null, null, ref );
				
			case _:
				trace( e.expr );
		}
		
		vo.filePosition = e.pos;
		return vo;
	}
	
	static public function getProperty( ident : String, field : String, assigned : Expr ) : PropertyVO
	{
		//trace( ident, field, assigned );
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
						
					case "true" | "false":
						type = ContextTypeList.BOOLEAN;
						
					case _:
						type = ContextTypeList.INSTANCE;
						ref = v;
						v = null;
				}
				
				propertyVO = new PropertyVO( ident, field, v, type, ref );
			
			case EConst(CInt(v)):
				propertyVO = new PropertyVO( ident, field, v, ContextTypeList.INT );
				
			case EConst(CFloat(v)):
				propertyVO = new PropertyVO( ident, field, v, ContextTypeList.FLOAT );
				
			case EConst(CString(v)):
				propertyVO = new PropertyVO( ident, field, v, ContextTypeList.STRING );
				
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
					var key = getArgument( ident, e1 );
					var value = getArgument( ident, e2 );
					var mapVO = new MapVO( key, value );
					trace( key );
					trace( value );
					mapVO.filePosition = param.pos;
					args.push( mapVO );
					
				case _:
					trace( param.expr );
			}
			
		}
		return [];
	}
}