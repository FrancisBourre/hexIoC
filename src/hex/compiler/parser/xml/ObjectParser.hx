package hex.compiler.parser.xml;

import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.core.ContextNameList;
import hex.ioc.core.ContextTypeList;
import hex.ioc.error.IAssemblingExceptionReporter;
import hex.ioc.parser.xml.XMLAttributeUtil;
import hex.ioc.parser.xml.XMLParserUtil;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.ioc.vo.MapVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;

/**
 * ...
 * @author Francis Bourre
 */
class ObjectParser extends AbstractXmlParser
{
	public function new() 
	{
		super();
	}
	
	override public function parse() : Void
	{
		var applicationContext 	= this.getApplicationAssembler().getApplicationContext( this._getRootApplicationContextName() );
		var iterator 			= this.getContextData().firstElement().elements();
		
		while ( iterator.hasNext() )
		{
			this._parseNode( iterator.next(), applicationContext );
		}
	}
	
	public function _parseNode( xml : Xml, applicationContext :  AbstractApplicationContext ) : Void
	{
		var assembler = this.getApplicationAssembler();
		
		var identifier = xml.get( ContextAttributeList.ID );
		if ( identifier == null )
		{
			this._exceptionReporter.throwMissingIDException( xml );
		}

		var type 				: String;
		var args 				: Array<Dynamic>;
		var mapType				: Array<String>;
		var staticRef			: String;
		
		var factory 			: String;
		var singleton 			: String;
		var injectInto			: Bool;
		var injectorCreation	: Bool;
		var ifList				: Array<String>;
		var ifNotList			: Array<String>;

		// Build object.
		type = xml.get( ContextAttributeList.TYPE );

		if ( type == ContextTypeList.XML )
		{
			factory 			= xml.get( ContextAttributeList.PARSER_CLASS );
			var arg 			= new ConstructorVO( identifier, ContextTypeList.STRING, [ xml.firstElement().toString() ] );
			arg.filePosition 	= this._exceptionReporter.getPosition( xml.firstElement() );
			
			var constructorVO 			= new ConstructorVO( identifier, type, [ arg ], factory );
			constructorVO.filePosition 	= this._exceptionReporter.getPosition( xml );
			constructorVO.ifList 		= XMLParserUtil.getIfList( xml );
			constructorVO.ifNotList 	= XMLParserUtil.getIfNotList( xml );

			assembler.buildObject( applicationContext, constructorVO );
		}
		else
		{
			factory 			= xml.get( ContextAttributeList.FACTORY );
			singleton 			= xml.get( ContextAttributeList.SINGLETON_ACCESS );
			injectInto			= xml.get( ContextAttributeList.INJECT_INTO ) == "true";
			mapType 			= XMLParserUtil.getMapType( xml );
			staticRef 			= xml.get( ContextAttributeList.STATIC_REF );
			injectorCreation 	= xml.get( ContextAttributeList.INJECTOR_CREATION ) == "true";
			ifList 				= XMLParserUtil.getIfList( xml );
			ifNotList 			= XMLParserUtil.getIfNotList( xml );
		
			if ( type == null )
			{
				type = staticRef != null ? ContextTypeList.STATIC_VARIABLE : ContextTypeList.STRING;
			}

			var strippedType = type != null ? type.split( '<' )[ 0 ] : null;
			if ( strippedType == ContextTypeList.HASHMAP || type == ContextTypeList.SERVICE_LOCATOR || type == ContextTypeList.MAPPING_CONFIG )
			{
				args = this._getMapArguments( identifier, xml, this._exceptionReporter );

				for ( arg in args )
				{
					if ( arg.getPropertyKey() != null )
					{
						if ( arg.getPropertyKey().type == ContextTypeList.CLASS )
						{
							this._importHelper.includeClass( arg.getPropertyKey().arguments[0] );
						}
					}
					
					if ( arg.getPropertyValue() != null )
					{
						if ( arg.getPropertyValue().type == ContextTypeList.CLASS )
						{
							this._importHelper.includeClass( arg.getPropertyValue().arguments[0] );
						}
					}
				}
			}
			else
			{
				args = [];
				var iterator = xml.elementsNamed( ContextNameList.ARGUMENT );

				if ( iterator.hasNext() )
				{
					while ( iterator.hasNext() )
					{
						var node = iterator.next();
						var arg = XMLParserUtil._getConstructorVOFromXML( identifier, node );
						arg.filePosition = this._exceptionReporter.getPosition( node );
						
						if ( arg.staticRef != null )
						{
							var type = this._importHelper.getClassFullyQualifiedNameFromStaticRef( arg.staticRef );
							try 
							{
								this._importHelper.forceCompilation( type.split( '<' )[ 0 ] );
								
							} catch ( e : String ) 
							{
								this._exceptionReporter.throwMissingTypeException( type.length > 0 ? type : arg.staticRef, node, ContextAttributeList.STATIC_REF );
							}
						}
						else
						{
							if ( arg.className == ContextTypeList.CLASS )
							{
								try 
								{
									this._importHelper.forceCompilation( ( arg.arguments[ 0 ] ).split( '<' )[ 0 ] );
									
								} catch ( e : String ) 
								{
									this._exceptionReporter.throwMissingTypeException( arg.arguments[ 0 ], node, ContextAttributeList.VALUE );
								}
							}
						}
						args.push( arg );
					}
				}
				else
				{
					var value : String = XMLAttributeUtil.getValue( xml );
					if ( value != null ) 
					{
						var arg = new ConstructorVO( identifier, ContextTypeList.STRING, [ xml.get( ContextAttributeList.VALUE ) ] );
						args.push( arg ); 
					}
				}
			}
			
			if ( type != ContextTypeList.STATIC_VARIABLE )
			{
				try
				{
					this._importHelper.forceCompilation( type.split( '<' )[ 0 ] );
				}
				catch ( e : String )
				{
					this._exceptionReporter.throwMissingTypeException( type, xml, ContextAttributeList.TYPE );
				}
			}
			else
			{
				var t = this._importHelper.getClassFullyQualifiedNameFromStaticRef( staticRef );
				
				try
				{
					this._importHelper.forceCompilation( t.split( '<' )[ 0 ] );
				}
				catch ( e : String )
				{
					this._exceptionReporter.throwMissingTypeException( t, xml, ContextAttributeList.STATIC_REF );
				}
			}

			var constructorVO 			= new ConstructorVO( identifier, type, args, factory, singleton, injectInto, null, mapType, staticRef, injectorCreation );
			constructorVO.ifList 		= ifList;
			constructorVO.ifNotList 	= ifNotList;
			constructorVO.filePosition 	= constructorVO.ref == null ? this._exceptionReporter.getPosition( xml ) : this._exceptionReporter.getPosition( xml, ContextAttributeList.REF );

			assembler.buildObject( applicationContext, constructorVO );

			// Build property.
			var propertyIterator = xml.elementsNamed( ContextNameList.PROPERTY );
			while ( propertyIterator.hasNext() )
			{
				var property = propertyIterator.next();
				var staticRef = property.get( ContextAttributeList.STATIC_REF );
				
				if ( staticRef != null )
				{
					var type = this._importHelper.getClassFullyQualifiedNameFromStaticRef( staticRef );

					try
					{
						this._importHelper.forceCompilation( type.split( '<' )[ 0 ] );
					}
					catch ( e : String )
					{
						this._exceptionReporter.throwMissingTypeException( type, property, ContextAttributeList.STATIC_REF );
					}
				}
				
				var propertyVO = new PropertyVO ( 	identifier, 
													XMLAttributeUtil.getName( property ),
													XMLAttributeUtil.getValue( property ),
													XMLAttributeUtil.getType( property ),
													XMLAttributeUtil.getRef( property ),
													XMLAttributeUtil.getMethod( property ),
													XMLAttributeUtil.getStaticRef( property ) );
				
				propertyVO.filePosition = propertyVO.ref == null ? this._exceptionReporter.getPosition( property ) : this._exceptionReporter.getPosition( property, ContextAttributeList.REF );
				propertyVO.ifList 		= XMLParserUtil.getIfList( xml );
				propertyVO.ifNotList 	= XMLParserUtil.getIfNotList( xml );
				
				assembler.buildProperty( applicationContext, propertyVO );
			}

			// Build method call.
			var methodCallIterator = xml.elementsNamed( ContextNameList.METHOD_CALL );
			while( methodCallIterator.hasNext() )
			{
				var methodCallItem = methodCallIterator.next();

				args = [];
				var iterator = methodCallItem.elementsNamed( ContextNameList.ARGUMENT );

				while ( iterator.hasNext() )
				{
					var node 			= iterator.next();
					var arg 			= XMLParserUtil._getConstructorVOFromXML( identifier, node );
					arg.filePosition 	= this._exceptionReporter.getPosition( node );
					
					if ( arg.staticRef != null )
					{
						var type = this._importHelper.getClassFullyQualifiedNameFromStaticRef( arg.staticRef );
						try 
						{
							var type = this._importHelper.getClassFullyQualifiedNameFromStaticRef( staticRef );
							this._importHelper.forceCompilation( type.split( '<' )[ 0 ] );
							
						} catch ( e : String ) 
						{
							this._exceptionReporter.throwMissingTypeException( type.length > 0 ? type : arg.staticRef, node, ContextAttributeList.STATIC_REF );
						}
					}
					else
					{
						if ( arg.className == ContextTypeList.CLASS )
						{
							try 
							{
								this._importHelper.forceCompilation( ( arg.arguments[ 0 ] ).split( '<' )[ 0 ] );
								
							} catch ( e : String ) 
							{
								this._exceptionReporter.throwMissingTypeException( arg.arguments[ 0 ], node, ContextAttributeList.VALUE );
							}
						}
					}
					
					args.push( arg );
				}
				
				var methodCallVO 			= new MethodCallVO( identifier, methodCallItem.get( ContextAttributeList.NAME ), args );
				methodCallVO.filePosition 	= this._exceptionReporter.getPosition( methodCallItem );
				methodCallVO.ifList 		= XMLParserUtil.getIfList( methodCallItem );
				methodCallVO.ifNotList 		= XMLParserUtil.getIfNotList( methodCallItem );
				
				assembler.buildMethodCall( applicationContext, methodCallVO );
			}

			// Build channel listener.
			var listenIterator = xml.elementsNamed( ContextNameList.LISTEN );
			while( listenIterator.hasNext() )
			{
				var listener = listenIterator.next();
				var channelName : String = listener.get( ContextAttributeList.REF );

				if ( channelName != null )
				{
					var listenerArgs : Array<DomainListenerVOArguments> = [];
					var iterator = listener.elementsNamed( ContextNameList.EVENT );

					while ( iterator.hasNext() )
					{
						var node = iterator.next();
						var listenerArg = XMLParserUtil.getEventArgument( node );
						listenerArg.filePosition = this._exceptionReporter.getPosition( node );
						
						//
						var staticRef = listenerArg.staticRef;
						if ( staticRef != null )
						{
							var type = this._importHelper.getClassFullyQualifiedNameFromStaticRef( staticRef );
							
							try
							{
								this._importHelper.forceCompilation( type.split( '<' )[ 0 ] );
							}
							catch ( e : String )
							{
								this._exceptionReporter.throwMissingTypeException( type, node, ContextAttributeList.STATIC_REF );
							}
						}
						
						listenerArgs.push( listenerArg );
					}

					var domainListenerVO 			= new DomainListenerVO( identifier, channelName, listenerArgs );
					domainListenerVO.filePosition 	= this._exceptionReporter.getPosition( listener );
					domainListenerVO.ifList 		= XMLParserUtil.getIfList( listener );
					domainListenerVO.ifNotList 		= XMLParserUtil.getIfNotList( listener );
					
					assembler.buildDomainListener( applicationContext, domainListenerVO );
				}
				else
				{
					this._exceptionReporter.throwMissingListeningReferenceException( xml, listener );
				}
			}
		}
	}
	
	function _getMapArguments( ownerID : String, xml : Xml, exceptionReporter : IAssemblingExceptionReporter<Xml> ) : Array<MapVO>
	{
		var args : Array<MapVO> = [];
		var iterator = xml.elementsNamed( ContextNameList.ITEM );

		while ( iterator.hasNext() )
		{
			var item = iterator.next();
			var keyList 	= item.elementsNamed( ContextNameList.KEY );
			var valueList 	= item.elementsNamed( ContextNameList.VALUE );
			
			if ( keyList.hasNext() )
			{
				var keyNode 	= keyList.next();
				var valueNode 	= valueList.next();
				var key 		= XMLParserUtil._getAttributes( keyNode );
				var value 		= XMLParserUtil._getAttributes( valueNode );
				var keyVO 		= XMLParserUtil._getConstructorVO( ownerID, key );

				keyVO.filePosition = exceptionReporter.getPosition( keyNode );
				var valueVO	= XMLParserUtil._getConstructorVO( ownerID, value );
				valueVO.filePosition = exceptionReporter.getPosition( valueNode );
				var mapVO = new MapVO( keyVO, valueVO, XMLAttributeUtil.getMapName( item ), XMLAttributeUtil.getAsSingleton( item ), XMLAttributeUtil.getInjectInto( item ) );
				mapVO.filePosition = exceptionReporter.getPosition( item );
				args.push( mapVO );
			}
		}

		return args;
	}
}