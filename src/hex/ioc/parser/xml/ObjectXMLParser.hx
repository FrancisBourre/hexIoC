package hex.ioc.parser.xml;

import hex.error.Exception;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.core.ContextNameList;
import hex.ioc.core.ContextTypeList;
import hex.ioc.error.ParsingException;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;

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
		var iterator = this.getXMLContext().firstElement().elements();
		while ( iterator.hasNext() )
		{
			this._parseNode( iterator.next() );
		}

		this._handleComplete();
	}
	
	function _parseNode( xml : Xml ) : Void
	{
		var applicationContext : AbstractApplicationContext = this.getApplicationContext();

		var identifier : String = XMLAttributeUtil.getID( xml );
		if ( identifier == null )
		{
			throw new ParsingException( this + " encounters parsing error with '" + xml.nodeName + "' node. You must set an id attribute." );
		}

		var type 		: String;
		var args 		: Array<Dynamic>;
		var factory 	: String;
		var singleton 	: String;
		var injectInto	: Bool;
		var mapType		: String;
		var staticRef	: String;
		var ifList		: Array<String>;
		var ifNotList	: Array<String>;

		// Build object.
		type = XMLAttributeUtil.getType( xml );

		if ( type == ContextTypeList.XML )
		{
			factory = xml.get( ContextAttributeList.PARSER_CLASS );
			args = [ new ConstructorVO( identifier, ContextTypeList.STRING, [ xml.firstElement().toString() ] ) ];
			
			var constructorVO 		= new ConstructorVO( identifier, type, args, factory );
			constructorVO.ifList 	= XMLParserUtil.getIfList( xml );
			constructorVO.ifNotList = XMLParserUtil.getIfNotList( xml );

			this.getApplicationAssembler( ).buildObject( applicationContext, constructorVO );
		}
		else
		{
			args 		= ( type == ContextTypeList.HASHMAP || type == ContextTypeList.SERVICE_LOCATOR || type == ContextTypeList.MAPPING_CONFIG ) ? XMLParserUtil.getMapArguments( identifier, xml ) : XMLParserUtil.getArguments( identifier, xml, type );
			factory 	= XMLAttributeUtil.getFactoryMethod( xml );
			singleton 	= XMLAttributeUtil.getSingletonAccess( xml );
			injectInto	= XMLAttributeUtil.getInjectInto( xml );
			mapType 	= XMLAttributeUtil.getMapType( xml );
			staticRef 	= XMLAttributeUtil.getStaticRef( xml );

			if ( type == null )
			{
				type = staticRef != null ? ContextTypeList.STATIC_VARIABLE : ContextTypeList.STRING;
			}
			
			var constructorVO 		= new ConstructorVO( identifier, type, args, factory, singleton, injectInto, null, mapType, staticRef );
			constructorVO.ifList 	= XMLParserUtil.getIfList( xml );
			constructorVO.ifNotList = XMLParserUtil.getIfNotList( xml );

			this.getApplicationAssembler( ).buildObject( applicationContext, constructorVO );

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
				
				propertyVO.ifList = XMLParserUtil.getIfList( xml );
				propertyVO.ifNotList = XMLParserUtil.getIfNotList( xml );
				
				this.getApplicationAssembler( ).buildProperty( applicationContext, propertyVO );
			}

			// Build method call.
			var methodCallIterator = xml.elementsNamed( ContextNameList.METHOD_CALL );
			while( methodCallIterator.hasNext() )
			{
				var methodCallItem 		= methodCallIterator.next();
				var methodCallVO 		= new MethodCallVO( identifier, XMLAttributeUtil.getName( methodCallItem ), XMLParserUtil.getMethodCallArguments( identifier, methodCallItem ) );
				methodCallVO.ifList 	= XMLParserUtil.getIfList( methodCallItem );
				methodCallVO.ifNotList 	= XMLParserUtil.getIfNotList( methodCallItem );
				
				this.getApplicationAssembler( ).buildMethodCall( applicationContext, methodCallVO );
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
					domainListenerVO.ifList 	= XMLParserUtil.getIfList( listener );
					domainListenerVO.ifNotList 	= XMLParserUtil.getIfNotList( listener );
					
					this.getApplicationAssembler().buildDomainListener( applicationContext, domainListenerVO );
				}
				else
				{
					throw new Exception( this + " encounters parsing error with '" + xml.nodeName + "' node, 'ref' attribute is mandatory in a 'listen' node." );
				}
			}
		}
	}
}