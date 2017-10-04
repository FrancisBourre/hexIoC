package hex.compiler.parser.flow;

#if macro
import haxe.macro.*;
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.compiletime.flow.AbstractExprParser;
import hex.compiletime.flow.parser.ExpressionParser;
import hex.compiletime.flow.parser.ExpressionUtil;
import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.StateTransitionVO;
import hex.ioc.vo.TransitionVO;

using hex.util.LambdaUtil;

/**
 * ...
 * @author Francis Bourre
 */
class StateParser extends AbstractExprParser<hex.factory.BuildRequest>
{
	var logger 				: hex.log.ILogger;
	var parser 				: ExpressionParser;
	
	static var _I = 0;

	public function new( parser : ExpressionParser ) 
	{
		super();
		
		this.logger 		= hex.log.LogManager.getLoggerByInstance( this );
		this.parser 		= parser;
	}
	
	override public function parse() : Void 
	{
		this.transformContextData
		( 
			function( exprs :Array<Expr> ) 
			{
				var transformation = exprs.transformAndPartition( _transform );
				transformation.is.map( _parseState );
				return transformation.isNot;
			}
		);
	}
	
	private function _transform( e : Expr ) : Transformation<Expr, StateExpr>
	{
		switch ( e )
		{
			case macro $i { id } = $value:

				switch ( value.expr )
				{
					case ECall( _.expr => EField( ref, field ), params ):

						var ident = ExpressionUtil.compressField( ref );
						if ( ident.split('.')[0] == 'state' )
						{
							var vo = new StateTransitionVO( id, null, null, [], [], [] );
							vo.filePosition = value.pos;
							return Transformed( {vo: vo, expr: value } );
						}
						
					case _:
				}

			case _:
		}
		
		return Original( e );
	}
	
	private function _parseState( se : StateExpr ) : Void
	{
		//stateTransitionVO.ifList 	= XmlUtil.getIfList( xml );
		//stateTransitionVO.ifNotList = XmlUtil.getIfNotList( xml );

		this._builder.build( STATE_TRANSITION( _getStateTransitionVO( se.expr, se.vo ) ) );
	}

	static function _getStateTransitionVO( e : Expr, vo : StateTransitionVO ) : StateTransitionVO
	{
		return switch( e.expr )
		{
			case ECall( _.expr => EField( ee, field ), params ):
				_processParam( field, params, vo , e.pos);
				return _getStateTransitionVO( ee, vo );
				
			case ECall( _.expr => EConst(CIdent(id)), params ):
				_processParam( id, params, vo, e.pos );
				return vo;
				
			default:
				return vo;
		}
	}
	
	static function _processParam( field : String, params : Array<Expr>, vo : StateTransitionVO, pos : Position )
	{
		var firstParameter = params.shift();

		switch( field )
		{
			case 'enter':
				vo.enterList.push( _getCommandMappingVO( firstParameter, params, pos ) );
				
			case 'exit':
				vo.exitList.push( _getCommandMappingVO( firstParameter, params, pos ) );
				
			case 'state':

				if ( firstParameter != null )
				{
					switch( firstParameter.expr )
					{
						case ECall( _.expr => EConst(CIdent(id)), params ):

							if ( id == 'ref' )
							{
								vo.instanceReference = ExpressionUtil.compressField( params[0] );
							}
							else if ( id == 'staticRef' )
							{
								vo.staticReference = ExpressionUtil.compressField( params[0] );
							}
							
						case _:
					}
				}
				else
				{
					
				}

			case 'transition':
				
				var messageReference = firstParameter.expr;
				var stateRef = params.shift().expr;
				var transitionVO = new TransitionVO();
				transitionVO.messageReference = switch( messageReference ) { case EConst( CIdent(ident) ): ident; case _: null; };
				transitionVO.stateReference = switch( stateRef ) { case EConst( CIdent(ident) ): ident; case _: null; };
				
				vo.transitionList.push( transitionVO );
				
			case _:
				trace('WTF');
				Context.error( 'WTF', pos );
		}
	}
	
	static function _getCommandMappingVO( firstParameter : Expr, params : Array<Expr>, pos : Position ) : CommandMappingVO
	{
		var commandClassName = null;
		var methodRef = null;
		
		switch( firstParameter.expr )
		{
			case ECall( _.expr => EConst( CIdent('method') ), p ):
				methodRef = ExpressionUtil.compressField( p[0] );
				
			case EField( ee, field ):
				commandClassName = ExpressionUtil.compressField( firstParameter );
				
			case wtf:
				trace( wtf );
		}
		
		return 
		{
			commandClassName: commandClassName, 
			fireOnce: _isFiredOnce( params ), 
			contextOwner: _getContextOwner( params ),
			methodRef: methodRef,
			filePosition: pos
		};
	}
	
	static function _getContextOwner( params : Array<Expr> ) : String
	{
		for ( param in params )
		{
			switch( param.expr )
			{
				case ECall( _.expr => EConst( CIdent('contextOwner') ), p ):
					params.remove( param );
					return switch( p[0].expr )
					{
						case EConst( CIdent(owner) ): owner;
						case _: null;
					}

				case _:
			}
		}
		
		return null;
	}
	
	static function _isFiredOnce( params : Array<Expr> ) : Bool
	{
		for ( param in params )
		{
			switch( param.expr )
			{
				case EConst( CIdent('fireOnce') ) :
					params.remove( param );
					return true;
					
				case _:
			}
		}
		
		return false;
	}
}

typedef StateExpr =
{
	vo 			: StateTransitionVO,
	expr 		: Expr
}
#end