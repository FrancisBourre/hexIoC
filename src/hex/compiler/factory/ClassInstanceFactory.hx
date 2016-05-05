package hex.compiler.factory;

import haxe.macro.Expr;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ClassInstanceFactory
{
	function new()
	{

	}

	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;
		var e : Expr = null;
		
		if ( constructorVO.ref != null )
		{
			e = ReferenceFactory.build( factoryVO );
		}
		else
		{
			if ( constructorVO.staticRef != null )
			{
				//constructorVO.result = ClassUtil.getStaticReference( constructorVO.staticRef );
			}
			else
			{
				var tp = MacroUtil.getPack( constructorVO.type );
				var typePath = MacroUtil.getTypePath( constructorVO.type );
				var idVar = constructorVO.ID;
				
				//build instance
				var singleton = constructorVO.singleton;
				var factory = constructorVO.factory;
				if ( factory != null )
				{
					if ( singleton != null )
					{
						e = macro { $p { tp }.$singleton().$factory( $a{ constructorVO.constructorArgs } ); };
						factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $e; } );
					}
					else
					{
						e = macro { $p { tp }.$factory( $a{ constructorVO.constructorArgs } ); };
						factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $e; } );
					}
				
				}
				else if ( singleton != null )
				{
					e = macro { $p { tp }.$singleton(); };
					factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $e; } );
				}
				else
				{
					e = macro { new $typePath( $a{ constructorVO.constructorArgs } ); };
					factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $e; } );
				}
			}

			/*if ( Std.is( constructorVO.result, IModule ) )
			{
				factoryVO.moduleLocator.register( constructorVO.ID, constructorVO.result );
			}

			if ( constructorVO.mapType != null )
			{
				var classToMap : Class<Dynamic> = Type.resolveClass( constructorVO.mapType );
				factoryVO.contextFactory.getApplicationContext().getBasicInjector().mapToValue( classToMap, constructorVO.result, constructorVO.ID );
			}*/
		}
		
		return e;
	}
	#end
}