package hex.compiler.parser.xml;
import hex.compiletime.xml.AbstractXmlParser;

#if macro
import haxe.macro.Context;
import hex.core.IApplicationContext;
import hex.factory.BuildRequest;
import hex.ioc.assembler.ApplicationContext;
import hex.compiletime.xml.XmlUtil;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.core.ContextNodeNameList;
import hex.core.ContextTypeList;
import hex.compiletime.error.IExceptionReporter;
import hex.ioc.parser.xml.XMLAttributeUtil;
import hex.ioc.parser.xml.XMLParserUtil;
import hex.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.vo.MapVO;
import hex.vo.MethodCallVO;
import hex.vo.PropertyVO;

/**
 * ...
 * @author Francis Bourre
 */
class ObjectParser extends AbstractXmlParser<BuildRequest>
{
	public function new() 
	{
		super();
	}
	
	override public function parse() : Void
	{
		var applicationContext 	= this.getApplicationAssembler().getApplicationContext( this._applicationContextName, ApplicationContext );
		var iterator 			= this._contextData.firstElement().elements();
		
		while ( iterator.hasNext() )
		{
			this._parseNode( iterator.next(), applicationContext );
		}
	}
	
	public function _parseNode( xml : Xml, applicationContext :  IApplicationContext ) : Void
	{
		var shouldConstruct = true;
		
		var identifier = xml.get( ContextAttributeList.ID );
		if ( identifier == null )
		{
			identifier = xml.get( ContextAttributeList.REF );
			
			if ( identifier != null )
			{
				shouldConstruct = false;
			}
			else
			{
				Context.error
				( 
					"Parsing error with '" + xml.nodeName + 
					"' node, 'id' attribute not found.", 
					this._positionTracker.getPosition( xml ) );
			}

		}

		var type 				: String;
		var args 				: Array<Dynamic>;
		var mapType				: Array<String>;
		var staticRef			: String;
		
		var factory 			: String;
		var staticCall 			: String;
		var injectInto			: Bool;
		var ifList				: Array<String>;
		var ifNotList			: Array<String>;

		// Build object.
		if ( shouldConstruct )
		{
			type = xml.get( ContextAttributeList.TYPE );
			
			if ( type == ContextTypeList.XML )
			{
				factory 					= xml.get( ContextAttributeList.PARSER_CLASS );
				var constructorVO 			= new ConstructorVO( identifier, type, [ xml.firstElement().toString() ], factory );
				constructorVO.filePosition 	= this._positionTracker.getPosition( xml );
				constructorVO.ifList 		= XmlUtil.getIfList( xml );
				constructorVO.ifNotList 	= XmlUtil.getIfNotList( xml );
				constructorVO.isPublic		= true;
				this._builder.build( OBJECT( constructorVO ) );
			}
			else
			{
				factory 			= xml.get( ContextAttributeList.FACTORY_METHOD );
				staticCall 			= xml.get( ContextAttributeList.STATIC_CALL );
				injectInto			= xml.get( ContextAttributeList.INJECT_INTO ) == "true";
				mapType 			= XMLParserUtil.getMapType( xml );
				staticRef 			= xml.get( ContextAttributeList.STATIC_REF );
				ifList 				= XmlUtil.getIfList( xml );
				ifNotList 			= XmlUtil.getIfNotList( xml );
			
				if ( type == null )
				{
					type = staticRef != null ? ContextTypeList.STATIC_VARIABLE : ContextTypeList.STRING;
				}

				var strippedType = type != null ? type.split( '<' )[ 0 ] : null;
				if ( strippedType == ContextTypeList.HASHMAP || type == ContextTypeList.MAPPING_CONFIG )
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
					var iterator = xml.elementsNamed( ContextNodeNameList.ARGUMENT );

					if ( iterator.hasNext() )
					{
						while ( iterator.hasNext() )
						{
							var node = iterator.next();
							var arg = ObjectParser._getConstructorVOFromXML( identifier, node );
							arg.filePosition = this._positionTracker.getPosition( node );
							
							if ( arg.staticRef != null )
							{
								var type = this._importHelper.getClassFullyQualifiedNameFromStaticVariable( arg.staticRef );
								try 
								{
									this._importHelper.forceCompilation( type.split( '<' )[ 0 ] );
									
								} catch ( e : String ) 
								{
									this._throwMissingTypeException( type.length > 0 ? type : arg.staticRef, node, ContextAttributeList.STATIC_REF );
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
										this._throwMissingTypeException( arg.arguments[ 0 ], node, ContextAttributeList.VALUE );
									}
								}
							}
							args.push( arg );
						}
					}
					else
					{
						//TODO please remove that shit
						var value : String = XMLAttributeUtil.getValue( xml );
						if ( value != null ) 
						{
							if 
							( 
								type == ContextTypeList.STRING ||
								type == ContextTypeList.INT ||
								type == ContextTypeList.UINT || 
								type == ContextTypeList.FLOAT || 
								type == ContextTypeList.BOOLEAN || 
								type == ContextTypeList.NULL ||
								type == ContextTypeList.CLASS
							)
							{
								args = [ xml.get( ContextAttributeList.VALUE ) ];
							}
							else 
							{
								var arg = new ConstructorVO( identifier, ContextTypeList.STRING, [ xml.get( ContextAttributeList.VALUE ) ] );
								args.push( arg ); 
							}
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
						this._throwMissingTypeException( type, xml, ContextAttributeList.TYPE );
					}
				}
				else
				{
					var t = this._importHelper.getClassFullyQualifiedNameFromStaticVariable( staticRef );
					
					try
					{
						this._importHelper.forceCompilation( t.split( '<' )[ 0 ] );
					}
					catch ( e : String )
					{
						this._throwMissingTypeException( t, xml, ContextAttributeList.STATIC_REF );
					}
				}

				var constructorVO 			= new ConstructorVO( identifier, type, args, factory, staticCall, injectInto, null, mapType, staticRef );
				constructorVO.ifList 		= ifList;
				constructorVO.ifNotList 	= ifNotList;
				constructorVO.filePosition 	= constructorVO.ref == null ? this._positionTracker.getPosition( xml ) : this._positionTracker.getPosition( xml, ContextAttributeList.REF );
				constructorVO.isPublic		= true;
				this._builder.build( OBJECT( constructorVO ) );
			}
		}

		// Build property.
		var propertyIterator = xml.elementsNamed( ContextNodeNameList.PROPERTY );
		while ( propertyIterator.hasNext() )
		{
			var property = propertyIterator.next();
			var staticRef = property.get( ContextAttributeList.STATIC_REF );
			
			if ( staticRef != null )
			{
				var type = this._importHelper.getClassFullyQualifiedNameFromStaticVariable( staticRef );

				try
				{
					this._importHelper.forceCompilation( type.split( '<' )[ 0 ] );
				}
				catch ( e : String )
				{
					this._throwMissingTypeException( type, property, ContextAttributeList.STATIC_REF );
				}
			}
			
			var propertyVO = new PropertyVO ( 	identifier, 
												XMLAttributeUtil.getName( property ),
												XMLAttributeUtil.getValue( property ),
												XMLAttributeUtil.getType( property ),
												XMLAttributeUtil.getRef( property ),
												XMLAttributeUtil.getMethod( property ),
												XMLAttributeUtil.getStaticRef( property ) );
			
			propertyVO.filePosition = propertyVO.ref == null ? this._positionTracker.getPosition( property ) : this._positionTracker.getPosition( property, ContextAttributeList.REF );
			propertyVO.ifList 		= XmlUtil.getIfList( xml );
			propertyVO.ifNotList 	= XmlUtil.getIfNotList( xml );

			this._builder.build( PROPERTY( propertyVO ) );
		}

		// Build method call.
		var methodCallIterator = xml.elementsNamed( ContextNodeNameList.METHOD_CALL );
		while( methodCallIterator.hasNext() )
		{
			var methodCallItem = methodCallIterator.next();

			args = [];
			var iterator = methodCallItem.elementsNamed( ContextNodeNameList.ARGUMENT );

			while ( iterator.hasNext() )
			{
				var node 			= iterator.next();
				var arg 			= ObjectParser._getConstructorVOFromXML( identifier, node );
				arg.filePosition 	= this._positionTracker.getPosition( node );
				
				if ( arg.staticRef != null )
				{
					var type = this._importHelper.getClassFullyQualifiedNameFromStaticVariable( arg.staticRef );
					try 
					{
						this._importHelper.forceCompilation( type );
						
					} catch ( e : String ) 
					{
						this._throwMissingTypeException( type.length > 0 ? type : arg.staticRef, node, ContextAttributeList.STATIC_REF );
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
							this._throwMissingTypeException( arg.arguments[ 0 ], node, ContextAttributeList.VALUE );
						}
					}
				}
				
				args.push( arg );
			}
			
			var methodCallVO 			= new MethodCallVO( identifier, methodCallItem.get( ContextAttributeList.NAME ), args );
			methodCallVO.filePosition 	= this._positionTracker.getPosition( methodCallItem );
			methodCallVO.ifList 		= XmlUtil.getIfList( methodCallItem );
			methodCallVO.ifNotList 		= XmlUtil.getIfNotList( methodCallItem );
			
			this._builder.build( METHOD_CALL( methodCallVO ) );
		}

		// Build channel listener.
		var listenIterator = xml.elementsNamed( ContextNodeNameList.LISTEN );
		while( listenIterator.hasNext() )
		{
			var listener = listenIterator.next();
			var channelName : String = listener.get( ContextAttributeList.REF );

			if ( channelName != null )
			{
				var listenerArgs : Array<DomainListenerVOArguments> = [];
				var iterator = listener.elementsNamed( ContextNodeNameList.EVENT );

				while ( iterator.hasNext() )
				{
					var node = iterator.next();
					var listenerArg = XMLParserUtil.getEventArgument( node );
					listenerArg.filePosition = this._positionTracker.getPosition( node );
					
					//
					var staticRef = listenerArg.staticRef;
					if ( staticRef != null )
					{
						var type = this._importHelper.getClassFullyQualifiedNameFromStaticVariable( staticRef );
						
						try
						{
							this._importHelper.forceCompilation( type.split( '<' )[ 0 ] );
						}
						catch ( e : String )
						{
							this._throwMissingTypeException( type, node, ContextAttributeList.STATIC_REF );
						}
					}
					
					listenerArgs.push( listenerArg );
				}

				var domainListenerVO 			= new DomainListenerVO( identifier, channelName, listenerArgs );
				domainListenerVO.filePosition 	= this._positionTracker.getPosition( listener );
				domainListenerVO.ifList 		= XmlUtil.getIfList( listener );
				domainListenerVO.ifNotList 		= XmlUtil.getIfNotList( listener );

				this._builder.build( DOMAIN_LISTENER( domainListenerVO ) );
			}
			else
			{
				Context.error
				( 
					"Parsing error with '" + xml.nodeName + 
						"' node, 'ref' attribute is mandatory in a 'listen' node.", 
					this._positionTracker.getPosition( listener ) );

			}
		}
		//

		
	}

	function _getMapArguments( ownerID : String, xml : Xml, exceptionReporter : IExceptionReporter<Xml> ) : Array<MapVO>
	{
		var args : Array<MapVO> = [];
		var iterator = xml.elementsNamed( ContextNodeNameList.ITEM );

		while ( iterator.hasNext() )
		{
			var item = iterator.next();
			var keyList 	= item.elementsNamed( ContextNodeNameList.KEY );
			var valueList 	= item.elementsNamed( ContextNodeNameList.VALUE );
			
			if ( keyList.hasNext() )
			{
				var keyNode 	= keyList.next();
				var valueNode 	= valueList.next();
				var key 		= XMLParserUtil._getAttributes( keyNode );
				var value 		= XMLParserUtil._getAttributes( valueNode );
				var keyVO 		= XMLParserUtil._getConstructorVO( ownerID, key );

				keyVO.filePosition = this._positionTracker.getPosition( keyNode );
				var valueVO	= XMLParserUtil._getConstructorVO( ownerID, value );
				valueVO.filePosition = this._positionTracker.getPosition( valueNode );
				var mapVO = new MapVO( keyVO, valueVO, XMLAttributeUtil.getMapName( item ), XMLAttributeUtil.getAsSingleton( item ), XMLAttributeUtil.getInjectInto( item ) );
				mapVO.filePosition = this._positionTracker.getPosition( item );
				args.push( mapVO );
			}
		}

		return args;
	}
	
	static function _getConstructorVOFromXML( ownerID : String, item : Xml ) : ConstructorVO
	{
		var method 		= item.get( ContextAttributeList.METHOD );
		var ref 		= item.get( ContextAttributeList.REF );
		var staticRef 	= item.get( ContextAttributeList.STATIC_REF );
		var factory 	= item.get( ContextAttributeList.FACTORY_METHOD );
		
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
}
#end