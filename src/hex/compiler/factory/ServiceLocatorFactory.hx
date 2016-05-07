package hex.compiler.factory;

import haxe.macro.Context;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.MapVO;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ServiceLocatorFactory
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
		
		var typePath = MacroUtil.getTypePath( "hex.config.stateful.ServiceLocator" );
		var e = macro { new $typePath(); };
		
		factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $e; } );
		
		var extVar = macro $i{ idVar };

		if ( args.length <= 0 )
		{
			Context.warning( "ServiceLocatorFactory.build(" + args + ") returns an empty ServiceConfig.", Context.currentPos() );

		} else
		{
			for ( item in args )
			{
				if ( item.key != null )
				{
					var a = [ item.key, item.value ];

					if ( item.mapName != null )
					{
						a.push( macro { $v { item.mapName } } );
					}
					
					factoryVO.expressions.push( macro @:mergeBlock { $extVar.addService( $a{ a } ); } );
					
				} else
				{
					Context.warning( "ServiceLocatorFactory.build() adds item with a 'null' key for '"  + item.value +"' value.", Context.currentPos() );
				}
			}
		}
		
		return e;
	}
	#end
}