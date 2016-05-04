package hex.ioc.control;

import hex.ioc.vo.FactoryVO;
import hex.data.IParser;
import hex.ioc.error.ParsingException;
import hex.ioc.vo.ConstructorVO;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class XmlFactory
{
	function new()
	{

	}

	static public function build( factoryVO : FactoryVO ) : Void
	{
		var constructorVO 	= factoryVO.constructorVO;
		var args 			= constructorVO.arguments;
		var factory 		= constructorVO.factory;

		if ( args != null ||  args.length > 0 )
		{
			#if macro
			var source : String = args[ 0 ].arguments[ 0 ];
			#else
			var source : String = args[ 0 ];
			#end
			
			if ( source.length > 0 )
			{
				if ( factory == null )
				{
					#if macro
					if ( !constructorVO.isProperty )
					{
						var idVar = constructorVO.argumentName != null ? constructorVO.argumentName : constructorVO.ID;
						factoryVO.expressions.push( macro @:mergeBlock { var $idVar = Xml.parse( $v { source } ); } );
					}
					#else
					constructorVO.result = Xml.parse( source );
					#end
				}
				else
				{
					#if macro
					if ( !constructorVO.isProperty )
					{
						var idVar = constructorVO.argumentName != null ? constructorVO.argumentName : constructorVO.ID;
						var typePath = MacroUtil.getTypePath( factory );
						var parser = "factory_" + constructorVO.ID;
						factoryVO.expressions.push( macro @:mergeBlock { var $parser = new $typePath(); } );
						
						var parserVar = macro $i{ parser };
						factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $parserVar.parse( Xml.parse( $v { source } ) ); } );
					}
					#else
					try
					{
						var parser : IParser = factoryVO.coreFactory.buildInstance( factory );
						constructorVO.result = parser.parse( Xml.parse( source ) );
					}
					catch ( error : Dynamic )
					{
						throw new ParsingException( "XmlFactory.build() failed to deserialize XML with '" + factory + "' deserializer class." );
					}
					#end
				}
			}
			else
			{
				#if debug
				trace( "XmlFactory.build() returns an empty XML." );
				#end
				
				#if macro
				var idVar = constructorVO.argumentName != null ? constructorVO.argumentName : constructorVO.ID;
				factoryVO.expressions.push( macro @:mergeBlock { var $idVar = Xml.parse( "" ); } );
				#else
				constructorVO.result = Xml.parse( "" );
				#end
			}
		}
		else
		{
			#if debug
			trace( "XmlFactory.build() returns an empty XML." );
			#end
			
			#if macro
			var idVar = constructorVO.argumentName != null ? constructorVO.argumentName : constructorVO.ID;
			factoryVO.expressions.push( macro @:mergeBlock { var $idVar = Xml.parse( "" ); } );
			#else
			constructorVO.result = Xml.parse( "" );
			#end
		}
	}
}