package hex.compiler.factory;

import haxe.macro.Context;
import hex.collection.HashMap;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.MapVO;

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

		var map = new HashMap<Dynamic, Dynamic>();
		var args : Array<MapVO> = cast constructorVO.arguments;
		
		var idVar = constructorVO.ID;
		
		//var typePath = MacroUtil.asTypePath( "hex.collection.HashMap" );
		//var e = macro { new $typePath(); };
		
		var e = Context.parseInlineString( "new HashMap<Dynamic, Dynamic>()", Context.currentPos() );
		factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $e; } );
		
		var extVar = macro $i{ idVar };

		if ( args.length == 0 )
		{
			Context.warning( "HashMapFactory.build(" + args + ") returns an empty HashMap.", Context.currentPos() );

		} else
		{
			for ( item in args )
			{
				if ( item.key != null )
				{
					var a = [ item.key, item.value ];
					factoryVO.expressions.push( macro @:mergeBlock { $extVar.put( $a{ a } ); } );
					
				} else
				{
					Context.warning( "HashMapFactory.build() adds item with a 'null' key for '"  + item.value +"' value.", Context.currentPos() );
				}
			}
		}

		constructorVO.result = map;

		if ( constructorVO.mapType != null )
		{
			factoryVO.contextFactory.getApplicationContext().getBasicInjector().mapToValue( HashMap, constructorVO.result, constructorVO.ID );
		}
		
		return e;
	}
	#end
}