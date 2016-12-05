package hex.compiler.factory;

import haxe.macro.Context;
import haxe.macro.Expr;
import hex.collection.HashMap;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.MapVO;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class HashMapFactory
{
	function new()
	{

	}

	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;
		var args : Array<MapVO> = cast constructorVO.arguments;
		
		var idVar = constructorVO.ID;
		var params = [ TPType( macro:Dynamic ), TPType( macro:Dynamic ) ];
		var typePath = MacroUtil.getTypePath( Type.getClassName( HashMap ), params );
		var e = macro @:pos( constructorVO.filePosition ) { new $typePath(); };
		
		factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $e; } );
		
		var extVar = macro $i{ idVar };
		if ( args.length == 0 )
		{
			Context.warning( "HashMapFactory.build(" + args + ") returns an empty HashMap.", constructorVO.filePosition );

		} else
		{
			for ( item in args )
			{
				if ( item.key != null )
				{
					var a = [ item.key, item.value ];
					factoryVO.expressions.push( macro @:pos( constructorVO.filePosition ) @:mergeBlock { $extVar.put( $a{ a } ); } );
					
				} else
				{
					Context.warning( "HashMapFactory.build() adds item with a 'null' key for '"  + item.value +"' value.", constructorVO.filePosition );
				}
			}
			
			if ( constructorVO.mapTypes != null )
			{
				var mapTypes = constructorVO.mapTypes;
				for ( mapType in mapTypes )
				{
					//Check if class exists
					FactoryUtil.checkTypeParamsExist( mapType, constructorVO.filePosition );
					
					//Map it
					factoryVO.expressions.push
					( 
						macro @:pos( constructorVO.filePosition ) 
							@:mergeBlock { __applicationContextInjector
								.mapClassNameToValue( $v { mapType }, $extVar, $v { idVar } ); } 
					);
				}
			}
		}
		
		return e;
	}
	#end
}