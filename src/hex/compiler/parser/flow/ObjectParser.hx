package hex.compiler.parser.flow;
import hex.ioc.core.ContextTypeList;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;

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
			var id 		: String;
			var type 	: String;
			var args 	: Array<Dynamic> = [];
			
			var e = i.next();
			switch ( e.expr )
			{
				case EBinop( OpAssign, _.expr => EConst(CIdent(ident)), value ):

					id = ident;
					
					switch( value.expr )
					{
						case EConst(CString(v)):
							
							type = ContextTypeList.STRING;
							args = [ new ConstructorVO( id, type, [ v ] ) ];
							
						
						case EConst(CInt(v)):
							
							type = ContextTypeList.INT;
							args = [ new ConstructorVO( id, type, [ v ] ) ];
							
						
						case EConst(CIdent(v)):
							
							switch( v )
							{
								case "null":
									type = ContextTypeList.NULL;
									
								case "true" | "false":
									type = ContextTypeList.BOOLEAN;
									
								case _:
									trace( v );
							}

							args = [ new ConstructorVO( id, type, [ v ] ) ];
							
						case ENew( t, params ):
							
							var pack = t.pack.join( '.' );
							type = pack == "" ? t.name : pack + '.' + t.name;

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
												args = ExpressionUtil.getMapArguments( id, values );
												
											case _:
												trace( params[ 0 ].expr );
										}
										//
									}
									
									
								case _ :
									if ( params.length > 0 )
									{
										var it = params.iterator();
										while ( it.hasNext() )
											args.push( ExpressionUtil.getArgument( id, it.next() ) );
									}
							}

						case EObjectDecl( fields ):
							
							type = ContextTypeList.OBJECT;
							
							var it = fields.iterator();
							while ( it.hasNext() )
							{
								var argument = it.next();
								var propertyVO = ExpressionUtil.getProperty( id, argument.field, argument.expr );
								this._applicationAssembler.buildProperty( this.getApplicationContext(), propertyVO );
							}
							
						case EArrayDecl( values ):
							
							type = ContextTypeList.ARRAY;
							
							var it = values.iterator();
							while ( it.hasNext() )
								args.push( ExpressionUtil.getArgument( id, it.next() ) );
						
						case _:
							trace( value.expr );
							
					}
					
					var constructorVO = new ConstructorVO( id, type, args );
					constructorVO.filePosition = e.pos;
					this._applicationAssembler.buildObject( this.getApplicationContext(), constructorVO );
				
				case EBinop( 	OpAssign, 
								_.expr => EField( _.expr => EConst(CIdent(ident)), field ), 
								assigned ):
					
					var propertyVO : PropertyVO;
					propertyVO = ExpressionUtil.getProperty( ident, field, assigned );
					this._applicationAssembler.buildProperty( this.getApplicationContext(), propertyVO );
				
				case ECall( _.expr => EField( _.expr => EConst(CIdent(ident)), field ), params ):
					
					var it = params.iterator();
					var methodArguments = [];
					
					while ( it.hasNext() )
						methodArguments.push( ExpressionUtil.getArgument( ident, it.next() ) );

					var methodCallVO = new MethodCallVO( ident, field, methodArguments );
					this._applicationAssembler.buildMethodCall( this.getApplicationContext(), methodCallVO );
					
				case _:
					trace( e.expr );
			}
		}
	}
}