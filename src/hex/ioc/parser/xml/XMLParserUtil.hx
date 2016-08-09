package hex.ioc.parser.xml;

import haxe.macro.ExprTools.ExprArrayTools;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.core.ContextNameList;
import hex.ioc.core.ContextTypeList;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.ioc.vo.MapVO;

using StringTools;

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
				args.push( XMLParserUtil._getConstructorVOFromXML( ownerID, iterator.next() ) );
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
	
	public static function _getConstructorVOFromXML( ownerID : String, item : Xml ) : ConstructorVO
	{
		var method 		= item.get( ContextAttributeList.METHOD );
		var ref 		= item.get( ContextAttributeList.REF );
		var staticRef 	= item.get( ContextAttributeList.STATIC_REF );
		var factory 	= item.get( ContextAttributeList.FACTORY );
		
		if ( method != null )
		{
			return new ConstructorVO( null, ContextTypeList.FUNCTION, [ method ] );

		} else if ( ref != null )
		{
			return new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, false, item.get( ContextAttributeList.REF ) );

		} else if ( staticRef != null /*&& factory == null*/ )
		{
			return new ConstructorVO( null, ContextTypeList.STATIC_VARIABLE, null, null, null, false, null, null, item.get( ContextAttributeList.STATIC_REF ) );

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
	
	public static function _getConstructorVO( ownerID : String, item : Dynamic ) : ConstructorVO
	{
		var type 		= item.type;
		var method 		= item.method;
		var ref 		= item.ref;
		var staticRef 	= item.staticRef;
		var value 		= item.value;
		var factory 	= item.factory;

		if ( method != null )
		{
			return new ConstructorVO( null, ContextTypeList.FUNCTION, [ method ] );

		} else if ( ref != null )
		{
			return new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, false, ref );

		} else if ( staticRef != null /*&& factory == null*/ )
		{
			return new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, false, null, null, staticRef );

		} else
		{
			if ( type == null )
			{
				type = ContextTypeList.STRING;
			}

			return new ConstructorVO( ownerID, type, [ value ] );
		}
	}

	public static function getMethodCallArguments( ownerID : String, xml : Xml ) : Array<ConstructorVO>
	{
		var args : Array<ConstructorVO> = [];
		var iterator = xml.elementsNamed( ContextNameList.ARGUMENT );

		while ( iterator.hasNext() )
		{
			args.push( _getConstructorVOFromXML( ownerID, iterator.next() ) );
		}
		
		return args;
	}

	public static function getEventArguments( xml : Xml ) : Array<DomainListenerVOArguments>
	{
		var args : Array<DomainListenerVOArguments> = [];
		var iterator = xml.elementsNamed( ContextNameList.EVENT );

		while ( iterator.hasNext() )
		{
			args.push( XMLParserUtil.getEventArgument( iterator.next() ) );
		}

		return args;
	}
	
	public static function getEventArgument( item : Xml ) : DomainListenerVOArguments
	{
		var domainListenerVOArguments = new DomainListenerVOArguments();
		domainListenerVOArguments.staticRef 						= item.get( ContextAttributeList.STATIC_REF );
		domainListenerVOArguments.method 							= item.get( ContextAttributeList.METHOD );
		domainListenerVOArguments.strategy 							= item.get( ContextAttributeList.STRATEGY );
		domainListenerVOArguments.injectedInModule 					= item.get( ContextAttributeList.INJECTED_IN_MODULE ) == "true";
		return domainListenerVOArguments;
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
				var key 	= XMLParserUtil._getAttributes( keyList.next() );
				var value 	= XMLParserUtil._getAttributes( valueList.next() );			
				args.push( new MapVO( XMLParserUtil._getConstructorVO( ownerID, key ), XMLParserUtil._getConstructorVO( ownerID, value ), XMLAttributeUtil.getMapName( item ), XMLAttributeUtil.getAsSingleton( item ) ) );
			}
		}

		return args;
	}

	public static function _getAttributes( xml : Xml ) : Dynamic
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
		var s = XMLAttributeUtil.getIf( xml );
		return s != null ? s.split( "," ) : null;
	}
	
	static public function getIfNotList( xml : Xml ) : Array<String>
	{
		var s = XMLAttributeUtil.getIfNot( xml );
		return s != null ? s.split( "," ) : null;
	}
	
	static public function getMapType( xml : Xml ) : Array<String>
	{
		var s = xml.get( ContextAttributeList.MAP_TYPE );
		if ( s != null )
		{
			var a = s.split( "," );
			return [ for ( e in a ) e.trim() ];
		}
		
		return null;
	}
}