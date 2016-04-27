package hex.ioc.control;

import hex.ioc.vo.FactoryVO;
import hex.data.IParser;
import hex.ioc.error.ParsingException;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class XmlFactory
{
	public function new()
	{

	}

	static public function build( factoryVO : FactoryVO ) : Void
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;

		var args : Array<Dynamic> 	= constructorVO.arguments;
		var factory : String 		= constructorVO.factory;

		if ( args != null ||  args.length > 0 )
		{
			var source : String = args[ 0 ];

			if ( source.length > 0 )
			{
				if ( factory == null )
				{
					constructorVO.result = Xml.parse( source );
				}
				else
				{
					try
					{
						var parser : IParser = factoryVO.coreFactory.buildInstance( factory );
						constructorVO.result = parser.parse( Xml.parse( source ) );
					}
					catch ( error : Dynamic )
					{
						throw new ParsingException( "XmlFactory.build() failed to deserialize XML with '" + factory + "' deserializer class." );
					}
				}
			}
			else
			{
				#if debug
				trace( "XmlFactory.build() returns an empty XML." );
				#end
				
				constructorVO.result = Xml.parse( "" );
			}
		}
		else
		{
			#if debug
			trace( "XmlFactory.build() returns an empty XML." );
			#end
			
			constructorVO.result = Xml.parse( "" );
		}
	}
}