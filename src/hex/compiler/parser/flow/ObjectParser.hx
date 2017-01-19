package hex.compiler.parser.flow;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.TypeTools;
import hex.ioc.core.ContextTypeList;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.MethodCallVO;

/**
 * ...
 * @author Francis Bourre
 */
class ObjectParser extends AbstractExprParser
{
	public function new() 
	{
		super();
	}
	
	override public function parse() : Void
	{
		var exprs = this._getExpressions();

		var i = exprs.iterator();
		while ( i.hasNext() )
		{
			this._parseExpression( i.next() );
		}
	}
	
	#if macro
	private function _parseExpression( e : Expr ) : Void
	{
		switch ( e )
		{
			case macro $i { ident } = $value:
				var constructorVO = this._getConstructorVO( ident, value );
				this._builder.build( OBJECT( constructorVO ) );
			
			case macro $i{ident}.$field = $assigned:	
				var propertyVO = ExpressionUtil.getProperty( ident, field, assigned );
				this._builder.build( PROPERTY( propertyVO ) );
			
			case macro $i{ident}.$field( $a{params} ):
				
				var it = params.iterator();
				var methodArguments = [];
				
				while ( it.hasNext() )
					methodArguments.push( ExpressionUtil.getArgument( ident, it.next() ) );

				var methodCallVO = new MethodCallVO( ident, field, methodArguments );
				this._builder.build( METHOD_CALL( methodCallVO ) );
			
			case macro @inject_into($a{args}) $i{ident} = $value:
				var constructorVO = this._getConstructorVO( ident, value );
				constructorVO.injectInto = true;
				this._builder.build( OBJECT( constructorVO ) );
						
			case macro @injector_creation $i{ident} = $value:	
				var constructorVO = this._getConstructorVO( ident, value );
				constructorVO.injectorCreation = true;
				this._builder.build( OBJECT( constructorVO ) );
				
			case macro @map_type($a{args}) $i{ident} = $value:
				var constructorVO = this._getConstructorVO( ident, value );
				constructorVO.mapTypes = args.map( function( e ) return switch( e.expr ) 
				{ 
					case EConst(CString( mapType )) : mapType; 
					case _: "";
				} );
				this._builder.build( OBJECT( constructorVO ) );
				
			case _:
				trace( e.expr );
		}
	}
	
	function _getConstructorVO( ident : String, value : Expr ) : ConstructorVO 
	{
		var constructorVO : ConstructorVO;
		
		switch( value.expr )
		{
			case EConst(CString(v)):
				constructorVO = new ConstructorVO( ident, ContextTypeList.STRING, [ v ] );
			
			case EConst(CInt(v)):
				constructorVO = new ConstructorVO( ident, ContextTypeList.INT, [ v ] );
				
			case EConst(CIdent(v)):
				
				switch( v )
				{
					case "null":
						constructorVO = new ConstructorVO( ident, ContextTypeList.NULL, [ v ] );
						
					case "true" | "false":
						constructorVO = new ConstructorVO( ident, ContextTypeList.BOOLEAN, [ v ] );
						
					case _:
						trace( v );
				}
				
			case ENew( t, params ):
				constructorVO = this._getVOFromNewExpr( ident, t, params );
				constructorVO.type = ExprTools.toString( value ).split( 'new' )[ 1 ].split( '(' )[ 0 ];
				
			case EObjectDecl( fields ):
				constructorVO = new ConstructorVO( ident, ContextTypeList.OBJECT, [] );
				
				var it = fields.iterator();
				while ( it.hasNext() )
				{
					var argument = it.next();
					var propertyVO = ExpressionUtil.getProperty( ident, argument.field, argument.expr );
					this._builder.build( PROPERTY( propertyVO ) );
				}
				
			case EArrayDecl( values ):
				constructorVO = new ConstructorVO( ident, ContextTypeList.ARRAY, [] );
				
				var it = values.iterator();
				while ( it.hasNext() )
					constructorVO.arguments.push( ExpressionUtil.getArgument( ident, it.next() ) );
					
			case EField( e, field ):
				
				var className = ExpressionUtil.compressField( e.expr, field );
				var exp = Context.parse( '(null: ${className})', e.pos );

				switch( exp.expr )
				{
					case EParenthesis( _.expr => ECheckType( ee, TPath(p) ) ):
						
						if ( p.sub != null )
						{
							constructorVO = new ConstructorVO( ident, ContextTypeList.STATIC_VARIABLE, [], null, null, false, null, null, className );

						}
						else
						{
							constructorVO = new ConstructorVO( ident, ContextTypeList.CLASS, [ className ] );
						}
						
					case _:
						trace( exp );
				}
				
			case ECall( _.expr => EField( e, field ), params ):

				switch( e.expr )
				{
					case EField( ee, ff ):
						constructorVO = new ConstructorVO( ident, ExpressionUtil.compressField( e.expr ), [], null, field );
						
					case ECall( ee, pp ):

						var call = ExpressionUtil.compressField( ee.expr );
						var a = call.split( '.' );
						var staticCall = a.pop();
						var factory = field;
						var type = a.join( '.' );
						
						constructorVO = new ConstructorVO( ident, type, [], factory, staticCall );
					
					case EConst(CIdent('Xml')) if ( field == 'parse' ):
						if ( params.length > 0 )
						{
							switch( params[ 0 ].expr )
							{
								case EConst(CString(xml)):
									if ( params.length == 1 )
									{
										constructorVO = new ConstructorVO( ident, ContextTypeList.XML, [xml]  );
									}
									else if ( params.length == 2 )
									{
										switch( params[ 1 ].expr )
										{
											case EField( ee, ff ):
												var factory = ExpressionUtil.compressField( params[ 1 ].expr );
												constructorVO = new ConstructorVO( ident, ContextTypeList.XML, [xml], factory  );

											case _:
										}
									}
									
									
								case _:
									trace( params[ 0 ].expr );
							}
						}
						
					case _:
						trace( e.expr );
				}
				
				if ( params.length > 0 )
				{
					var it = params.iterator();
					while ( it.hasNext() )
						constructorVO.arguments.push( ExpressionUtil.getArgument( ident, it.next() ) );
				}
				
			case _:
				trace( value.expr );
				constructorVO = new ConstructorVO( ident );
				//break;
				
		}
		
		constructorVO.filePosition = value.pos;
		return constructorVO;
	}
	
	function _getVOFromNewExpr( ident : String, t : TypePath, params : Array<Expr> ) : ConstructorVO
	{
		var constructorVO : ConstructorVO;
		
		var pack = t.pack.join( '.' );
		var type = pack == "" ? t.name : pack + '.' + t.name;

		switch ( type )
		{
			case ContextTypeList.HASHMAP | 
					ContextTypeList.SERVICE_LOCATOR | 
						ContextTypeList.MAPPING_CONFIG:
				
				if ( params.length > 0 )
				{
					switch( params[ 0 ].expr )
					{
						case EArrayDecl( values ):
							constructorVO = new ConstructorVO( ident, ExpressionUtil.getFullClassDeclaration( t ), ExpressionUtil.getMapArguments( ident, values ) );
							
						case _:
							trace( params[ 0 ].expr );
					}
					//
				}
				
			case _ :
				constructorVO = new ConstructorVO( ident, type, [] );
				
				if ( params.length > 0 )
				{
					var it = params.iterator();
					while ( it.hasNext() )
						constructorVO.arguments.push( ExpressionUtil.getArgument( ident, it.next() ) );
				}
		}
		
		return constructorVO;
	}
	#end
}