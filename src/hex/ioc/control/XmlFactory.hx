package hex.ioc.control;

import hex.data.IParser;
import hex.error.PrivateConstructorException;
import hex.runtime.error.ParsingException;
import hex.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;

/**
 * ...
 * @author Francis Bourre
 */
class XmlFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }

	static public function build( factoryVO : FactoryVO ) : Xml
	{
		var result : Xml 	= null;
		var constructorVO 	= factoryVO.constructorVO;
		var args 			= constructorVO.arguments;
		var factory 		= constructorVO.factory;

		if ( args != null ||  args.length > 0 )
		{
			var source : String = args[ 0 ];

			if ( source.length > 0 )
			{
				if ( factory == null )
				{
					result = Xml.parse( source );
				}
				else
				{
					try
					{
						var parser : IParser<Dynamic> = factoryVO.contextFactory.getCoreFactory().buildInstance( new ConstructorVO( null, factory ) );
						result = parser.parse( Xml.parse( source ) );
					}
					catch ( error : Dynamic )
					{
						throw new ParsingException( "XmlFactory fails to deserialize XML with '" + factory + "' class." );
					}
				}
			}
			else
			{
				#if debug
				trace( "XmlFactory returns an empty XML." );
				#end

				result = Xml.parse( "" );
			}
		}
		else
		{
			#if debug
			trace( "XmlFactory returns an empty XML." );
			#end

			result = Xml.parse( "" );
		}
		
		return result;
	}
}