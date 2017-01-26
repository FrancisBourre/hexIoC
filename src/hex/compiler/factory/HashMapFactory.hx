package hex.compiler.factory;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import hex.error.PrivateConstructorException;
import hex.ioc.vo.FactoryVO;

/**
 * ...
 * @author Francis Bourre
 */
class HashMapFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }

	#if macro
	static public function build( factoryVO : FactoryVO ) : Expr
	{
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		var args 				= MapArgumentFactory.build( factoryVO );
		
		var e = Context.parseInlineString( "new " + constructorVO.type + "()", constructorVO.filePosition );
		if ( constructorVO.shouldAssign )
		{
			var varType = TypeTools.toComplexType( Context.typeof( e ) );
			var result 	= macro @:pos( constructorVO.filePosition ) var $idVar : $varType = $e;
			
			if ( args.length == 0 )
			{
				#if debug
				Context.warning( "Empty HashMap built.", constructorVO.filePosition );
				#end

			} else
			{
				for ( item in args )
				{
					if ( item.key != null )
					{
						var a = [ item.key, item.value ];
						
						//Fill with arguments
						result = macro 	@:pos( constructorVO.filePosition ) 
						@:mergeBlock 
						{
							$result; 
							$i{ idVar }.put( $a{ a } ); 
						};
						
					} else
					{
						#if debug
						Context.warning( "'null' key for '"  + item.value +"' value added.", constructorVO.filePosition );
						#end
					}
				}
			}
			
			return result;
		}
		else
		{
			return macro @:pos( constructorVO.filePosition ) $e;
		}
	}
	#end
}