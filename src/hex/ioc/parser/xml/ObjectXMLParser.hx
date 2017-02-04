package hex.ioc.parser.xml;

import hex.compiletime.xml.XmlUtil;
import hex.error.Exception;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.core.ContextNameList;
import hex.core.ContextTypeList;
import hex.runtime.error.ParsingException;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;
import hex.runtime.xml.AbstractXMLParser;

/**
 * ...
 * @author Francis Bourre
 */
class ObjectXMLParser extends AbstractXMLParser
{
	public function new() 
	{
		super();
	}
	
	override public function parse() : Void
	{
		var iterator = this._contextData.firstElement().elements();
		while ( iterator.hasNext() )
		{
			this._parseNode( iterator.next() );
		}
	}
	
	function _parseNode( xml : Xml ) : Void
	{
		var shouldConstruct = true;
		
		var identifier : String = XMLAttributeUtil.getID( xml );
		if ( identifier == null )
		{
			identifier = XMLAttributeUtil.getRef( xml );
			
			if ( identifier != null )
			{
				shouldConstruct = false;
			}
			else
			{
				throw new ParsingException( this + " encounters parsing error with '" + xml.nodeName + "' node. You must set an id attribute." );
			}
		}

		var type 				: String;
		var args 				: Array<Dynamic>;
		var factory 			: String;
		var staticCall 			: String;
		var injectInto			: Bool;
		var injectorCreation	: Bool;
		var mapType				: Array<String>;
		var staticRef			: String;
		var ifList				: Array<String>;
		var ifNotList			: Array<String>;

		// Build object.
		if ( shouldConstruct )
		{
			type = XMLAttributeUtil.getType( xml );

			if ( type == ContextTypeList.XML )
			{
				factory = xml.get( ContextAttributeList.PARSER_CLASS );
				args = [ xml.firstElement().toString() ];
				
				var constructorVO 		= new ConstructorVO( identifier, type, args, factory );
				constructorVO.ifList 	= XmlUtil.getIfList( xml );
				constructorVO.ifNotList = XmlUtil.getIfNotList( xml );

				this._builder.build( OBJECT( constructorVO ) );
			}
			else
			{
				var strippedType 	= type != null ? type.split( '<' )[ 0 ] : type;
				args 				= ( strippedType == ContextTypeList.HASHMAP || type == ContextTypeList.MAPPING_CONFIG ) ? XMLParserUtil.getMapArguments( identifier, xml ) : XMLParserUtil.getArguments( identifier, xml, type );
				factory 			= XMLAttributeUtil.getFactoryMethod( xml );
				staticCall 			= XMLAttributeUtil.getStaticCall( xml );
				injectInto			= XMLAttributeUtil.getInjectInto( xml );
				injectorCreation	= XMLAttributeUtil.getInjectorCreation( xml );
				mapType 			= XMLParserUtil.getMapType( xml );
				staticRef 			= XMLAttributeUtil.getStaticRef( xml );

				if ( type == null )
				{
					type = staticRef != null ? ContextTypeList.STATIC_VARIABLE : ContextTypeList.STRING;
				}
				
				var constructorVO 		= new ConstructorVO( identifier, type, args, factory, staticCall, injectInto, null, mapType, staticRef, injectorCreation );
				constructorVO.ifList 	= XmlUtil.getIfList( xml );
				constructorVO.ifNotList = XmlUtil.getIfNotList( xml );

				this._builder.build( OBJECT( constructorVO ) );
			}
		}
		

		// Build property.
		var propertyIterator = xml.elementsNamed( ContextNameList.PROPERTY );
		while ( propertyIterator.hasNext() )
		{
			var property = propertyIterator.next();
			var propertyVO = new PropertyVO( 	identifier, 
												XMLAttributeUtil.getName( property ),
												XMLAttributeUtil.getValue( property ),
												XMLAttributeUtil.getType( property ),
												XMLAttributeUtil.getRef( property ),
												XMLAttributeUtil.getMethod( property ),
												XMLAttributeUtil.getStaticRef( property ) );
			
			propertyVO.ifList = XmlUtil.getIfList( xml );
			propertyVO.ifNotList = XmlUtil.getIfNotList( xml );
			
			this._builder.build( PROPERTY( propertyVO ) );
		}

		// Build method call.
		var methodCallIterator = xml.elementsNamed( ContextNameList.METHOD_CALL );
		while( methodCallIterator.hasNext() )
		{
			var methodCallItem 		= methodCallIterator.next();
			var methodCallVO 		= new MethodCallVO( identifier, XMLAttributeUtil.getName( methodCallItem ), XMLParserUtil.getMethodCallArguments( identifier, methodCallItem ) );
			methodCallVO.ifList 	= XmlUtil.getIfList( methodCallItem );
			methodCallVO.ifNotList 	= XmlUtil.getIfNotList( methodCallItem );
			
			this._builder.build( METHOD_CALL( methodCallVO ) );
		}

		// Build channel listener.
		var listenIterator = xml.elementsNamed( ContextNameList.LISTEN );
		while( listenIterator.hasNext() )
		{
			var listener = listenIterator.next();
			var channelName : String = XMLAttributeUtil.getRef( listener );

			if ( channelName != null )
			{
				var domainListenerVO 		= new DomainListenerVO( identifier, channelName, XMLParserUtil.getEventArguments( listener ) );
				domainListenerVO.ifList 	= XmlUtil.getIfList( listener );
				domainListenerVO.ifNotList 	= XmlUtil.getIfNotList( listener );
				
				this._builder.build( DOMAIN_LISTENER( domainListenerVO ) );
			}
			else
			{
				throw new Exception( this + " encounters parsing error with '" + xml.nodeName + "' node, 'ref' attribute is mandatory in a 'listen' node." );
			}
		}

	}
}