package hex.compiler.factory;

import haxe.macro.Context;
import haxe.macro.TypeTools;
import hex.error.PrivateConstructorException;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.MapVO;

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
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;
		var args : Array<MapVO> = cast constructorVO.arguments;
		
		var idVar 	= constructorVO.ID;
		var e 	= Context.parseInlineString( "new " + constructorVO.type + "()", constructorVO.filePosition );
		var varType = TypeTools.toComplexType( Context.typeof( e ) );
		factoryVO.expressions.push( macro @:mergeBlock { var $idVar : $varType = $e; } );
		
		/*var params = [ TPType( macro:Dynamic ), TPType( macro:Dynamic ) ];
		var typePath = MacroUtil.getTypePath( Type.getClassName( HashMap ), params );*/
	
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
					
					//Remove whitespaces
					mapType = mapType.split( ' ' ).join( '' );
					
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