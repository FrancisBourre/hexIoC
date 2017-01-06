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
		var constructorVO 	= factoryVO.constructorVO;
		var args 			= constructorVO.arguments;
		var factory 		= constructorVO.factory;

		if ( args != null ||  args.length > 0 )
		{
			var source : String = args[ 0 ].arguments[ 0 ];
			
			if ( source.length > 0 )
			{
				if ( factory == null )
				{
					if ( constructorVO.shouldAssign )
					{
						var idVar = constructorVO.ID;
						factoryVO.expressions.push
						( 
							macro 	@:pos( constructorVO.filePosition ) 
									@:mergeBlock 
									{ 
										var $idVar = Xml.parse( $v { source } ); 
									} 
						);
					}
				}
				else
				{
					if ( constructorVO.shouldAssign )
					{
						var idVar 		= constructorVO.ID;
						var typePath 	= MacroUtil.getTypePath( factory, constructorVO.filePosition );
						var parser 		= 'factory_' + constructorVO.ID;
						
						factoryVO.expressions.push
						( 
							macro 	@:pos( constructorVO.filePosition ) 
									@:mergeBlock 
									{ 
										var $parser = new $typePath();
									} 
						);
						
						factoryVO.expressions.push
						( 
							macro 	@:pos( constructorVO.filePosition ) 
									@:mergeBlock 
									{ 
										var $idVar = $i{ parser }.parse( Xml.parse( $v { source } ) ); 
									} 
						);
					}
				}
			}
			else
			{
				#if debug
				Context.warning( "XmlFactory.build() returns an empty XML.", constructorVO.filePosition );
				#end
				
				var idVar = constructorVO.ID;
				factoryVO.expressions.push( macro @:mergeBlock { var $idVar = Xml.parse( '' ); } );
			}
		}
		else
		{
			#if debug
			Context.warning( "XmlFactory.build() returns an empty XML.", constructorVO.filePosition );
			#end

			var idVar = constructorVO.ID;
			factoryVO.expressions.push( macro @:mergeBlock { var $idVar = Xml.parse( '' ); } );
		}
		
		return null;
	}
	#end
}