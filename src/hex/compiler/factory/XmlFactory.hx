package hex.compiler.factory;

import haxe.macro.Context;
import haxe.macro.Expr;
import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class XmlFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }

	#if macro
	static public function build( factoryVO : FactoryVO ) : Expr
	{
		var result : Expr 	= null;
		var constructorVO 	= factoryVO.constructorVO;
		var idVar 			= constructorVO.ID;
		var args 			= constructorVO.arguments;
		var factory			= constructorVO.factory;

		if ( args != null ||  args.length > 0 )
		{
			//TODO simplify
			var source : String = args[ 0 ].arguments[ 0 ];
			
			if ( source.length > 0 )
			{
				if ( factory == null )
				{
					result = macro @:pos( constructorVO.filePosition ) Xml.parse( $v { source } ); 
				}
				else
				{
					var typePath 	= MacroUtil.getTypePath( factory, constructorVO.filePosition );
					result = macro 	@:pos( constructorVO.filePosition ) 
									( new $typePath() ).parse( Xml.parse( $v { source } ) );
				}
			}
			else
			{
				#if debug
				Context.warning( "Empty XML.", constructorVO.filePosition );
				#end
				
				result = macro Xml.parse( '' );
			}
		}
		else
		{
			#if debug
			Context.warning( "Empty XML.", constructorVO.filePosition );
			#end

			result = macro Xml.parse( '' );
		}
		
		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $result:	
			macro @:pos( constructorVO.filePosition ) $result;
	}
	#end
}