package hex.compiler.parser.flow;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.TypeTools;
import hex.compiletime.flow.parser.ExpressionUtil;
import hex.core.ContextTypeList;
import hex.vo.ConstructorVO;
import hex.vo.MapVO;
import hex.vo.MethodCallVO;
import hex.vo.PropertyVO;
import hex.compiletime.flow.AbstractExprParser;

/**
 * ...
 * @author Francis Bourre
 */
class ObjectParser extends AbstractExprParser<hex.factory.BuildRequest>
{
	var logger : hex.log.ILogger;
	//static var logger = LogManager.getLoggerByClass(ExpressionUtil);
	
	public function new() 
	{
		super();
		this.logger = hex.log.LogManager.getLoggerByInstance( this );
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
	
	private function _parseExpression( e : Expr ) : Void
	{
		switch ( e )
		{
			case macro $i { ident } = $value:
				var constructorVO = this._getConstructorVO( ident, value );
				this._builder.build( OBJECT( constructorVO ) );
			
			case macro $i{ident}.$field = $assigned:	
				var propertyVO = ObjectParser.getProperty( ident, field, assigned );
				this._builder.build( PROPERTY( propertyVO ) );
			
			case macro $i{ident}.$field( $a{params} ):
				
				var it = params.iterator();
				var methodArguments = [];
				
				while ( it.hasNext() )
					methodArguments.push( ObjectParser.getArgument( ident, it.next() ) );

				var methodCallVO = new MethodCallVO( ident, field, methodArguments );
				this._builder.build( METHOD_CALL( methodCallVO ) );
			
			case macro @inject_into($a{args}) $i{ident} = $value:
				var constructorVO = this._getConstructorVO( ident, value );
				constructorVO.injectInto = true;
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
				//TODO remove
				//logger.error("Unknown expression");
				//logger.debug(e);
				//logger.debug(e.expr);
		}
		//logger.debug(e);
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
						logger.error( v );
				}
				
			case ENew( t, params ):
				constructorVO = ObjectParser.getVOFromNewExpr( ident, t, params );
				constructorVO.type = ExprTools.toString( value ).split( 'new ' )[ 1 ].split( '(' )[ 0 ];
				
			case EObjectDecl( fields ):
				constructorVO = new ConstructorVO( ident, ContextTypeList.OBJECT, [] );
				
				var it = fields.iterator();
				while ( it.hasNext() )
				{
					var argument = it.next();
					var propertyVO = ObjectParser.getProperty( ident, argument.field, argument.expr );
					this._builder.build( PROPERTY( propertyVO ) );
				}
				
			case EArrayDecl( values ):
				constructorVO = new ConstructorVO( ident, ContextTypeList.ARRAY, [] );
				values.map( function( e ) constructorVO.arguments.push( ObjectParser.getArgument( ident, e ) ) );
					
			case EField( e, field ):
				
				var className = ExpressionUtil.compressField( e, field );
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
						logger.error( exp );
				}
				
			case ECall( _.expr => EConst(CIdent(keyword)), params ):

				switch( keyword )
				{
					case 'xml':
						return hex.compiletime.flow.parser.custom.XmlParser.parse( ident, params, value );

					case 'mapping':
						return hex.compiletime.flow.parser.custom.MappingParser.parse( ident, params, value );
				
					case wtf:
						trace( wtf );
				}
				
			case ECall( _.expr => EField( e, field ), params ):

				switch( e.expr )
				{
					case EField( ee, ff ):
						constructorVO = new ConstructorVO( ident, ExpressionUtil.compressField( e ), [], null, field );
						
					case ECall( ee, pp ):

						var call = ExpressionUtil.compressField( ee );
						var a = call.split( '.' );
						var staticCall = a.pop();
						var factory = field;
						var type = a.join( '.' );
						
						constructorVO = new ConstructorVO( ident, type, [], factory, staticCall );
						
					case _:
						logger.error( e.expr );
				}
				
				if ( params.length > 0 )
				{
					var it = params.iterator();
					while ( it.hasNext() )
						constructorVO.arguments.push( ObjectParser.getArgument( ident, it.next() ) );
				}
				
			case _:
				logger.error( value.expr );
				constructorVO = new ConstructorVO( ident );
				//break;
		}
		
		constructorVO.filePosition = value.pos;
		return constructorVO;
	}
	
	static public function getArgument( ident : String, value : Expr ) : ConstructorVO
	{
		var constructorVO : ConstructorVO;

		switch( value.expr )
		{
			case EConst(CString(v)):
				//String
				constructorVO = new ConstructorVO( ident, ContextTypeList.STRING, [ v ] );

			case EConst(CInt(v)):
				//Int
				constructorVO = new ConstructorVO( ident, ContextTypeList.INT, [ v ] );

			case EConst(CFloat(v)):
				//Float
				constructorVO = new ConstructorVO( ident, ContextTypeList.FLOAT, [ v ] );

			case EConst(CIdent(v)):
				
				switch( v )
				{
					case "null":
						//null
						constructorVO =  new ConstructorVO( ident, ContextTypeList.NULL, [ 'null' ] );

					case "true" | "false":
						//Boolean
						constructorVO =  new ConstructorVO( ident, ContextTypeList.BOOLEAN, [ v ] );

					case _:
						//Object reference
						constructorVO =  new ConstructorVO( ident, ContextTypeList.INSTANCE, [ v ], null, null, null, v );
				}

			case EField( value, field ):
				//Property or method reference
				constructorVO =  new ConstructorVO( ident, ContextTypeList.INSTANCE, [], null, null, null, ExpressionUtil.compressField( value ) + '.' + field );
			
			case ENew( t, params ):
				constructorVO = ObjectParser.getVOFromNewExpr( ident, t, params );
				constructorVO.type = ExprTools.toString( value ).split( 'new ' )[ 1 ].split( '(' )[ 0 ];
				
			case EArrayDecl( values ):
				constructorVO = new ConstructorVO( ident, ContextTypeList.ARRAY, [] );
				var it = values.iterator();
				while ( it.hasNext() ) constructorVO.arguments.push( ObjectParser.getArgument( ident, it.next() ) );
			
			case ECall( _.expr => EConst(CIdent('mapping')), params ):

				for ( param in params )
				{
					switch( param.expr )
					{
						case EObjectDecl( fields ):

							var args = [];
							var it = fields.iterator();
							while ( it.hasNext() )
							{
								var argument = it.next();
								args.push( ObjectParser.getProperty( ident, argument.field, argument.expr ) );
							}

							constructorVO = new ConstructorVO( ident, ContextTypeList.MAPPING_DEFINITION, args );
							constructorVO.filePosition = param.pos;
							
						case _:
							trace( 'WTF' );
					}
				}
	
			case _:
				trace( value.expr );
				//logger.debug( value.expr );
		}

		constructorVO.filePosition = value.pos;
		return constructorVO;
	}
	
	static public function getVOFromNewExpr( ident : String, t : TypePath, params : Array<Expr> ) : ConstructorVO
	{
		var constructorVO : ConstructorVO;
		
		var pack = t.pack.join( '.' );
		var type = pack == "" ? t.name : pack + '.' + t.name;

		switch ( type )
		{
			case ContextTypeList.HASHMAP | 
					ContextTypeList.MAPPING_CONFIG:
				
				if ( params.length > 0 )
				{
					switch( params[ 0 ].expr )
					{
						case EArrayDecl( values ):
							constructorVO = new ConstructorVO( ident, ExpressionUtil.getFullClassDeclaration( t ), ObjectParser.getMapArguments( ident, values ) );
							
						case _:
							//logger.error( params[ 0 ].expr );
					}
					//
				}
				
			case ContextTypeList.MAPPING_DEFINITION:
				
				switch( params[0].expr )
				{
					case EObjectDecl( fields ):
						
						var args = [];
						var it = fields.iterator();
						while ( it.hasNext() )
						{
							var argument = it.next();
							args.push( ObjectParser.getProperty( ident, argument.field, argument.expr ) );
						}
						
						constructorVO = new ConstructorVO( ident, ContextTypeList.MAPPING_DEFINITION, args );
					case _:
						trace( 'WTF' );
				}
				
			case _ :
				constructorVO = new ConstructorVO( ident, type, [] );
				
				if ( params.length > 0 )
				{
					var it = params.iterator();
					while ( it.hasNext() )
						constructorVO.arguments.push( ObjectParser.getArgument( ident, it.next() ) );
				}
		}
		
		return constructorVO;
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
				
			case ENew( t, params ):
				
				var constructorVO = ObjectParser.getVOFromNewExpr( ident, t, params );
				//constructorVO.type = ExprTools.toString( assigned.expr ).split( 'new ' )[ 1 ].split( '(' )[ 0 ];
				propertyVO = new PropertyVO( ident, field, null, type, ref, null, null, constructorVO );
				
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
				
				var className = ExpressionUtil.compressField( e, ff );
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
						
						//logger.debug( exp );
				}
				
			case _:
				//logger.debug( assigned.expr );
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
					
					var key 	= ObjectParser.getArgument( ident, e1 );
					var value 	= ObjectParser.getArgument( ident, e2 );
					var mapVO 	= new MapVO( key, value );
					mapVO.filePosition = param.pos;
					args.push( mapVO );
					
				case _:
					
					//logger.debug( param.expr );
			}
		}
		
		return args;
	}
}
#end