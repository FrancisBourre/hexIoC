package hex.ioc.control;

import hex.data.IParser;
import hex.event.IEvent;
import hex.ioc.error.ParsingException;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class BuildXMLCommand extends AbstractBuildCommand
{
	override public function execute( ?e : IEvent ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;

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
						var parser : IParser = this._buildHelperVO.coreFactory.buildInstance( factory );
						constructorVO.result = parser.parse( Xml.parse( source ) );
					}
					catch ( error : Dynamic )
					{
						throw new ParsingException( this + ".execute() failed to deserialize XML with '" + factory + "' deserializer class." );
					}
				}
			}
			else
			{

				trace( this + ".execute() returns an empty XML." );
				constructorVO.result = Xml.parse( "" );
			}
		}
		else
		{

			trace( this + ".execute() returns an empty XML." );
			constructorVO.result = Xml.parse( "" );
		}
	}
}