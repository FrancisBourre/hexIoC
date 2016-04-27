package hex.ioc.parser.xml;

import hex.ioc.core.ContextAttributeList;
import hex.ioc.core.ContextNameList;
import hex.ioc.core.ContextTypeList;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.ioc.vo.MapVO;

/**
 * ...
 * @author Francis Bourre
 */
class XMLParserUtil
{
	function new() 
	{
		
	}
	
	public static function getArguments( ownerID : String, xml : Xml, type : String ) : Array<ConstructorVO>
	{
		var args : Array<ConstructorVO> = [];
		var iterator = xml.elementsNamed( ContextNameList.ARGUMENT );

		if ( iterator.hasNext() )
		{
			while ( iterator.hasNext() )
			{
				args.push( _getConstructorVO( ownerID, iterator.next() ) );
			}
		}
		else
		{
			var value : String = XMLAttributeUtil.getValue( xml );
			if ( value != null ) 
			{
				args.push( new ConstructorVO( ownerID, ContextTypeList.STRING, [ xml.get( ContextAttributeList.VALUE ) ] ) );
			}
		}

		return args;
	}
	
	static function _getConstructorVO( ownerID : String, item : Xml ) : ConstructorVO
	{
		var method 		= item.get( ContextAttributeList.METHOD );
		var ref 		= item.get( ContextAttributeList.REF );
		var staticRef 	= item.get( ContextAttributeList.STATIC_REF );
		
		
		if ( method != null )
		{
			return new ConstructorVO( null, ContextTypeList.FUNCTION, [ method ] );

		} else if ( ref != null )
		{
			return new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, false, item.get( ContextAttributeList.REF ) );

		} else if ( staticRef != null )
		{
			return new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, false, null, null, item.get( ContextAttributeList.STATIC_REF ) );

		} else
		{
			var type : String = item.get( ContextAttributeList.TYPE );
			
			if ( type == null )
			{
				type = ContextTypeList.STRING;
			}

			return new ConstructorVO( ownerID, type, [ item.get( ContextAttributeList.VALUE ) ] );
		}
	}

	public static function getMethodCallArguments( ownerID : String, xml : Xml ) : Array<ConstructorVO>
	{
		var args : Array<ConstructorVO> = [];
		var iterator = xml.elementsNamed( ContextNameList.ARGUMENT );

		while ( iterator.hasNext() )
		{
			args.push( _getConstructorVO( ownerID, iterator.next() ) );
		}
		
		return args;
	}

	public static function getEventArguments( xml : Xml ) : Array<DomainListenerVOArguments>
	{
		var args : Array<DomainListenerVOArguments> = [];
		var iterator = xml.elementsNamed( ContextNameList.EVENT );

		while ( iterator.hasNext() )
		{
			var item = iterator.next();
			
			var domainListenerVOArguments = new DomainListenerVOArguments();
			domainListenerVOArguments.name 								= item.get( ContextAttributeList.NAME );
			domainListenerVOArguments.staticRef 						= item.get( ContextAttributeList.STATIC_REF );
			domainListenerVOArguments.method 							= item.get( ContextAttributeList.METHOD );
			domainListenerVOArguments.strategy 							= item.get( ContextAttributeList.STRATEGY );
			domainListenerVOArguments.injectedInModule 					= item.get( ContextAttributeList.INJECTED_IN_MODULE ) == "true";
			args.push( domainListenerVOArguments );
		}

		return args;
	}
	
	public static function getMapArguments( ownerID : String, xml : Xml ) : Array<Dynamic>
	{
		var args : Array<Dynamic> = [];
		var iterator = xml.elementsNamed( ContextNameList.ITEM );

		while ( iterator.hasNext() )
		{
			var item = iterator.next();

			var keyList 	= item.elementsNamed( ContextNameList.KEY );
			var valueList 	= item.elementsNamed( ContextNameList.VALUE );
			
			if ( keyList.hasNext() )
			{
				args.push( { 	mapName:XMLAttributeUtil.getMapName( item ), 
								key:XMLParserUtil._getAttributes( keyList.next() ), 
								value:XMLParserUtil._getAttributes( valueList.next() ) } 
							);
			}
		}
		
		/*if ( type == ContextTypeList.HASHMAP || type == ContextTypeList.SERVICE_LOCATOR )
		{
			for ( index in 0...length )
			{
				obj = args[ index ];
				args[ index ] = new MapVO( _getConstructorVO( ownerID, obj.key ), _getConstructorVO( ownerID, obj.value ), obj.mapName );
			}
		}*/
		
		var length = args.length;
		for ( index in 0...length )
		{
			var obj = args[ index ];
			args[ index ] = new MapVO( _getConstructorVO( ownerID, obj.key ), _getConstructorVO( ownerID, obj.value ), obj.mapName );
		}

		return args;
	}

	public static function getItems( ownerID : String, xml : Xml ) : Array<Dynamic>
	{
		var args : Array<Dynamic> = [];
		var iterator = xml.elementsNamed( ContextNameList.ITEM );

		while ( iterator.hasNext() )
		{
			var item = iterator.next();

			var keyList 	= item.elementsNamed( ContextNameList.KEY );
			var valueList 	= item.elementsNamed( ContextNameList.VALUE );
			
			if ( keyList.hasNext() )
			{
				args.push( { 	mapName:XMLAttributeUtil.getMapName( item ), 
								key:XMLParserUtil._getAttributes( keyList.next() ), 
								value:XMLParserUtil._getAttributes( valueList.next() ) } 
							);
			}
		}

		return args;
	}

	static function _getAttributes( xml : Xml ) : Dynamic
	{
		var obj : Dynamic = {};
		var iterator = xml.attributes();
		
		while ( iterator.hasNext() )
		{
			var attribute = iterator.next();
			Reflect.setField( obj, attribute, xml.get( attribute ) );
		}

		return obj;
	}
	
	static public function getIfList( xml : Xml ) : Array<String>
	{
		var s : String = XMLAttributeUtil.getIf( xml );
		return s != null ? s.split( "," ) : null;
	}
	
	static public function getIfNotList( xml : Xml ) : Array<String>
	{
		var s : String = XMLAttributeUtil.getIfNot( xml );
		return s != null ? s.split( "," ) : null;
	}
}