package hex.compiler.parser.flow;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.TypeTools;
import hex.compiletime.flow.parser.ExpressionParser;
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
	var parser : ExpressionParser;
	//
	
	public function new() 
	{
		super();
		this.logger = hex.log.LogManager.getLoggerByInstance( this );
		this.parser = 
		{
			parseProperty: 		hex.compiletime.flow.parser.expr.PropertyParser.parse, 
			parseType: 			hex.compiletime.flow.parser.expr.TypeParser.parse, 
			parseArgument: 		hex.compiletime.flow.parser.expr.ArgumentParser.parse, 
			parseMapArgument:	hex.compiletime.flow.parser.expr.MapArgumentParser.parse,
			
			typeParser:		
			[
				ContextTypeList.HASHMAP 			=> hex.compiletime.flow.parser.custom.HashMapParser.parse,
				ContextTypeList.MAPPING_CONFIG		=> hex.compiletime.flow.parser.custom.MappingConfigParser.parse,
				ContextTypeList.MAPPING_DEFINITION	=> hex.compiletime.flow.parser.custom.MappingParser.parse
			],
			
			methodParser:		
			[
				'mapping' 							=> hex.compiletime.flow.parser.custom.MappingParser.parse,
				'xml' 								=> hex.compiletime.flow.parser.custom.XmlParser.parse
			]
		};
	}
	
	override public function parse() : Void this._getExpressions().map( this._parseExpression );

	private function _parseExpression( e : Expr ) : Void
	{
		switch ( e )
		{
			case macro $i { ident } = $value:
				this._builder.build( OBJECT( this._getConstructorVO( ident, value ) ) );
			
			case macro $i{ident}.$field = $assigned:	
				var propertyVO = this.parser.parseProperty( this.parser, ident, field, assigned );
				this._builder.build( PROPERTY( propertyVO ) );
			
			case macro $i{ident}.$field( $a{params} ):
				var args = params.map( function(param) return this.parser.parseArgument(this.parser, ident, param) );
				this._builder.build( METHOD_CALL( new MethodCallVO( ident, field, args ) ) );
			
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
				constructorVO = this.parser.parseType( this.parser, ident, value );
				constructorVO.type = ExprTools.toString( value ).split( 'new ' )[ 1 ].split( '(' )[ 0 ];
				
			case EObjectDecl( fields ):
				constructorVO = new ConstructorVO( ident, ContextTypeList.OBJECT, [] );
				fields.map( function(field) this._builder.build( 
					PROPERTY( this.parser.parseProperty( this.parser, ident, field.field, field.expr ) )
				) );
				
			case EArrayDecl( values ):
				constructorVO = new ConstructorVO( ident, ContextTypeList.ARRAY, [] );
				values.map( function( e ) constructorVO.arguments.push( this.parser.parseArgument( this.parser, ident, e ) ) );
					
			case EField( e, field ):
				
				var className = ExpressionUtil.compressField( e, field );
				var exp = Context.parse( '(null: ${className})', e.pos );

				switch( exp.expr )
				{
					case EParenthesis( _.expr => ECheckType( ee, TPath(p) ) ):
						
						constructorVO =
						if ( p.sub != null )
						{
							new ConstructorVO( ident, ContextTypeList.STATIC_VARIABLE, [], null, null, false, null, null, className );

						}
						else
						{
							new ConstructorVO( ident, ContextTypeList.CLASS, [ className ] );
						}
						
					case _:
						logger.error( exp );
				}
				
			case ECall( _.expr => EConst(CIdent(keyword)), params ):
				return this.parser.methodParser.get( keyword )( this.parser, ident, params, value );
				
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
					constructorVO.arguments = params.map( function (e) return this.parser.parseArgument( this.parser, ident, e ) );
				}
				
			case _:
				logger.error( value.expr );
				constructorVO = new ConstructorVO( ident );
				//break;
		}
		
		constructorVO.filePosition = value.pos;
		return constructorVO;
	}
}
#end