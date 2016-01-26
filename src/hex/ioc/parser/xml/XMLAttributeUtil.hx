package hex.ioc.parser.xml;

import hex.error.PrivateConstructorException;
import hex.ioc.core.ContextAttributeList;

/**
 * ...
 * @author Francis Bourre
 */
class XMLAttributeUtil
{
	function new() 
	{
		throw new PrivateConstructorException( "'XMLAttributeUtil' class can't be instantiated." );
	}
	
	static public function getID( xml : Xml ) : String
	{
		return xml.get( ContextAttributeList.ID );
	}

	static public function getType( xml : Xml ) : String
	{
		return xml.get( ContextAttributeList.TYPE );
	}

	static public function getName( xml : Xml ) : String
	{
		return xml.get( ContextAttributeList.NAME );
	}

	static public function getRef( xml : Xml ) : String
	{
		return xml.get( ContextAttributeList.REF );
	}

	static public function getValue( xml : Xml ) : String
	{
		return xml.get( ContextAttributeList.VALUE );
	}

	static public function getFactoryMethod( xml : Xml ) : String
	{
		return xml.get( ContextAttributeList.FACTORY );
	}

	static public function getSingletonAccess( xml : Xml ) : String
	{
		return xml.get( ContextAttributeList.SINGLETON_ACCESS );
	}

	static public function getMethod( xml : Xml ) : String
	{
		return xml.get( ContextAttributeList.METHOD );
	}

	static public function getParserClass( xml : Xml ) : String
	{
		return xml.get( ContextAttributeList.PARSER_CLASS );
	}

	static public function getLocator( xml : Xml ) : String
	{
		return xml.get( ContextAttributeList.LOCATOR );
	}

	static public function getAttribute( xml : Xml, attName : String ) : String
	{
		return xml.get( attName );
	}

	static public function getMapType( xml : Xml ) : String
	{
		return xml.get( ContextAttributeList.MAP_TYPE );
	}

	static public function getMapName( xml : Xml ) : String
	{
		return xml.get( ContextAttributeList.MAP_NAME );
	}

	static public function getStaticRef( xml : Xml ) : String
	{
		return xml.get( ContextAttributeList.STATIC_REF );
	}
	
	static public function getCommandClass( xml : Xml ) : String
	{
		return xml.get( ContextAttributeList.COMMAND_CLASS );
	}
	
	static public function getFireOnce( xml : Xml ) : Bool
	{
		return xml.get( ContextAttributeList.FIRE_ONCE ) == "true";
	}
	
	static public function getContextOwner( xml : Xml ) : String
	{
		return xml.get( ContextAttributeList.CONTEXT_OWNER );
	}
}