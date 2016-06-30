package hex.compiler.parser.xml;

import com.tenderowls.xml176.Xml176Parser;
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.compiler.assembler.CompileTimeApplicationAssembler;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.core.ContextNameList;
import hex.ioc.core.ContextTypeList;
import hex.ioc.parser.xml.XMLAttributeUtil;
import hex.ioc.parser.xml.XMLParserUtil;
import hex.ioc.parser.xml.XmlAssemblingExceptionReporter;
import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.ioc.vo.MapVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;
import hex.ioc.vo.StateTransitionVO;
import hex.util.MacroUtil;

using StringTools;

/**
 * ...
 * @author Francis Bourre
 */
class XmlCompiler
{
	static var _importHelper	: ClassImportHelper;
	static var _assembler 		: CompileTimeApplicationAssembler;
	
	#if macro
	static function _parseNode( applicationContext : AbstractApplicationContext, xml : Xml, exceptionReporter : XmlAssemblingExceptionReporter ) : Void
	{
		var identifier : String = xml.get( ContextAttributeList.ID );
		if ( identifier == null )
		{
			exceptionReporter.throwMissingIDException( xml );
		}

		var type 		: String;
		var args 		: Array<Dynamic>;
		var mapType		: String;
		var staticRef	: String;
		
		var factory 	: String;
		var singleton 	: String;
		var injectInto	: Bool;
		var ifList		: Array<String>;
		var ifNotList	: Array<String>;

		// Build object.
		type = xml.get( ContextAttributeList.TYPE );

		if ( type == ContextTypeList.XML )
		{
			factory 			= xml.get( ContextAttributeList.PARSER_CLASS );
			var arg 			= new ConstructorVO( identifier, ContextTypeList.STRING, [ xml.firstElement().toString() ] );
			arg.filePosition 	= exceptionReporter._positionTracker.makePositionFromNode( xml.firstElement() );
			
			var constructorVO 			= new ConstructorVO( identifier, type, [ arg ], factory );
			constructorVO.filePosition 	= exceptionReporter._positionTracker.makePositionFromNode( xml );
			constructorVO.ifList 		= XMLParserUtil.getIfList( xml );
			constructorVO.ifNotList 	= XMLParserUtil.getIfNotList( xml );

			XmlCompiler._assembler.buildObject( applicationContext, constructorVO );
			XmlCompiler._importHelper.forceCompilation( factory );
		}
		else
		{
			factory 	= xml.get( ContextAttributeList.FACTORY );
			singleton 	= xml.get( ContextAttributeList.SINGLETON_ACCESS );
			injectInto	= xml.get( ContextAttributeList.INJECT_INTO ) == "true";
			mapType 	= xml.get( ContextAttributeList.MAP_TYPE );
			staticRef 	= xml.get( ContextAttributeList.STATIC_REF );
			ifList 		= XMLParserUtil.getIfList( xml );
			ifNotList 	= XMLParserUtil.getIfNotList( xml );
		
			if ( type == null )
			{
				type = staticRef != null ? ContextTypeList.STATIC_VARIABLE : ContextTypeList.STRING;
			}

			if ( type == ContextTypeList.HASHMAP || type == ContextTypeList.SERVICE_LOCATOR || type == ContextTypeList.MAPPING_CONFIG )
			{
				args = XmlCompiler.getMapArguments( identifier, xml, exceptionReporter );
				for ( arg in args )
				{
					if ( arg.getPropertyKey() != null )
					{
						if ( arg.getPropertyKey().type == ContextTypeList.CLASS )
						{
							XmlCompiler._importHelper.includeClass( arg.getPropertyKey().arguments[0] );
						}
					}
					
					if ( arg.getPropertyValue() != null )
					{
						if ( arg.getPropertyValue().type == ContextTypeList.CLASS )
						{
							XmlCompiler._importHelper.includeClass( arg.getPropertyValue().arguments[0] );
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
						arg.filePosition = exceptionReporter._positionTracker.makePositionFromNode( node );
						
						if ( arg.staticRef != null )
						{
							var type = ClassImportHelper.getClassFullyQualifiedNameFromStaticRef( arg.staticRef );
							try 
							{
								XmlCompiler._importHelper.forceCompilation( type );
								
							} catch ( e : String ) 
							{
								exceptionReporter.throwMissingTypeException( type.length > 0 ? type : arg.staticRef, node, ContextAttributeList.STATIC_REF );
							}
						}
						else
						{
							if ( arg.type == ContextTypeList.CLASS )
							{
								try 
								{
									XmlCompiler._importHelper.forceCompilation( arg.arguments[ 0 ] );
									
								} catch ( e : String ) 
								{
									exceptionReporter.throwMissingTypeException( arg.arguments[ 0 ], node, ContextAttributeList.VALUE );
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
					XmlCompiler._importHelper.forceCompilation( type );
				}
				catch ( e : String )
				{
					exceptionReporter.throwMissingTypeException( type, xml, ContextAttributeList.TYPE );
				}
			}
			else
			{
				var t = ClassImportHelper.getClassFullyQualifiedNameFromStaticRef( staticRef );
				
				try
				{
					XmlCompiler._importHelper.forceCompilation( t );
				}
				catch ( e : String )
				{
					exceptionReporter.throwMissingTypeException( t, xml, ContextAttributeList.STATIC_REF );
				}
			}
			
			try
			{
				XmlCompiler._importHelper.forceCompilation( mapType );
			}
			catch ( e : String )
			{
				exceptionReporter.throwMissingTypeException( mapType, xml, ContextAttributeList.MAP_TYPE );
			}
			
			try
			{
				XmlCompiler._importHelper.includeStaticRef( staticRef );
			}
			catch ( e : String )
			{
				exceptionReporter.throwMissingTypeException( staticRef, xml, ContextAttributeList.STATIC_REF );
			}
			
			if ( type == ContextTypeList.CLASS )
			{
				XmlCompiler._importHelper.forceCompilation( args[ 0 ].arguments[ 0 ] );
			}
			
			var constructorVO 			= new ConstructorVO( identifier, type, args, factory, singleton, injectInto, null, mapType, staticRef );
			constructorVO.ifList 		= ifList;
			constructorVO.ifNotList 	= ifNotList;
			constructorVO.filePosition 	= constructorVO.ref == null ? exceptionReporter._positionTracker.makePositionFromNode( xml ) : exceptionReporter._positionTracker.makePositionFromAttribute( xml, ContextAttributeList.REF );

			XmlCompiler._assembler.buildObject( applicationContext, constructorVO );

			// Build property.
			var propertyIterator = xml.elementsNamed( ContextNameList.PROPERTY );
			while ( propertyIterator.hasNext() )
			{
				var property = propertyIterator.next();
				var staticRef = property.get( ContextAttributeList.STATIC_REF );
				
				if ( staticRef != null )
				{
					var type = ClassImportHelper.getClassFullyQualifiedNameFromStaticRef( staticRef );

					try
					{
						XmlCompiler._importHelper.forceCompilation( type );
					}
					catch ( e : String )
					{
						exceptionReporter.throwMissingTypeException( type, property, ContextAttributeList.STATIC_REF );
					}
				}
				
				var propertyVO = new PropertyVO ( 	identifier, 
													XMLAttributeUtil.getName( property ),
													XMLAttributeUtil.getValue( property ),
													XMLAttributeUtil.getType( property ),
													XMLAttributeUtil.getRef( property ),
													XMLAttributeUtil.getMethod( property ),
													XMLAttributeUtil.getStaticRef( property ) );
				
				propertyVO.filePosition = propertyVO.ref == null ? exceptionReporter._positionTracker.makePositionFromNode( property ) : exceptionReporter._positionTracker.makePositionFromAttribute( property, ContextAttributeList.REF );
				propertyVO.ifList 		= XMLParserUtil.getIfList( xml );
				propertyVO.ifNotList 	= XMLParserUtil.getIfNotList( xml );
				
				XmlCompiler._assembler.buildProperty( applicationContext, propertyVO );
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
					arg.filePosition 	= exceptionReporter._positionTracker.makePositionFromNode( node );
					
					if ( arg.staticRef != null )
					{
						var type = ClassImportHelper.getClassFullyQualifiedNameFromStaticRef( arg.staticRef );
						try 
						{
							var type = ClassImportHelper.getClassFullyQualifiedNameFromStaticRef( staticRef );
							XmlCompiler._importHelper.forceCompilation( type );
							
						} catch ( e : String ) 
						{
							exceptionReporter.throwMissingTypeException( type.length > 0 ? type : arg.staticRef, node, ContextAttributeList.STATIC_REF );
						}
					}
					else
					{
						if ( arg.type == ContextTypeList.CLASS )
						{
							try 
							{
								XmlCompiler._importHelper.forceCompilation( arg.arguments[ 0 ] );
								
							} catch ( e : String ) 
							{
								exceptionReporter.throwMissingTypeException( arg.arguments[ 0 ], node, ContextAttributeList.VALUE );
							}
						}
					}
					
					args.push( arg );
				}
				
				var methodCallVO 			= new MethodCallVO( identifier, methodCallItem.get( ContextAttributeList.NAME ), args );
				methodCallVO.filePosition 	= exceptionReporter._positionTracker.makePositionFromNode( methodCallItem );
				methodCallVO.ifList 		= XMLParserUtil.getIfList( methodCallItem );
				methodCallVO.ifNotList 		= XMLParserUtil.getIfNotList( methodCallItem );
				
				XmlCompiler._assembler.buildMethodCall( applicationContext, methodCallVO );
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
						listenerArg.filePosition = exceptionReporter._positionTracker.makePositionFromNode( node );
						
						//
						var staticRef = listenerArg.staticRef;
						if ( staticRef != null )
						{
							var type = ClassImportHelper.getClassFullyQualifiedNameFromStaticRef( staticRef );
							
							try
							{
								XmlCompiler._importHelper.forceCompilation( type );
							}
							catch ( e : String )
							{
								exceptionReporter.throwMissingTypeException( type, node, ContextAttributeList.STATIC_REF );
							}
						}
						
						try
						{
							XmlCompiler._importHelper.forceCompilation( listenerArg.strategy );
						}
						catch ( e : String )
						{
							exceptionReporter.throwMissingTypeException( listenerArg.strategy, node, ContextAttributeList.STRATEGY );
						}

						listenerArgs.push( listenerArg );
					}

					var domainListenerVO 		= new DomainListenerVO( identifier, channelName, listenerArgs );
					domainListenerVO.filePosition 	= exceptionReporter._positionTracker.makePositionFromNode( listener );
					domainListenerVO.ifList 	= XMLParserUtil.getIfList( listener );
					domainListenerVO.ifNotList 	= XMLParserUtil.getIfNotList( listener );
					
					XmlCompiler._assembler.buildDomainListener( applicationContext, domainListenerVO );
				}
				else
				{
					exceptionReporter.throwMissingListeningReferenceException( xml, listener );
				}
			}
		}
	}
	
	static public function getMapArguments( ownerID : String, xml : Xml, exceptionReporter : XmlAssemblingExceptionReporter ) : Array<Dynamic>
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
				var keyNode 	= keyList.next();
				var valueNode 	= valueList.next();
				var key 		= XMLParserUtil._getAttributes( keyNode );
				var value 		= XMLParserUtil._getAttributes( valueNode );
				var keyVO 		= XMLParserUtil._getConstructorVO( ownerID, key );

				keyVO.filePosition = exceptionReporter._positionTracker.makePositionFromNode( keyNode );
				var valueVO	= XMLParserUtil._getConstructorVO( ownerID, value );
				valueVO.filePosition = exceptionReporter._positionTracker.makePositionFromNode( valueNode );
				var mapVO = new MapVO( keyVO, valueVO, XMLAttributeUtil.getMapName( item ), XMLAttributeUtil.getAsSingleton( item ) );
				mapVO.filePosition = exceptionReporter._positionTracker.makePositionFromNode( item );
				args.push( mapVO );
			}
		}

		return args;
	}
	
	static function _parseStateNodes( applicationContext : AbstractApplicationContext, xml : Xml, exceptionReporter : XmlAssemblingExceptionReporter ) : Void
	{
		var identifier = xml.get( ContextAttributeList.ID );
		if ( identifier == null )
		{
			exceptionReporter.throwMissingIDException( xml );
		}
		
		var staticReference 		= xml.get( ContextAttributeList.STATIC_REF );
		var instanceReference 		= xml.get( ContextAttributeList.REF );
		
		var enterList 				= XmlCompiler._getCommandList( xml, ContextNameList.ENTER, exceptionReporter );
		var exitList 				= XmlCompiler._getCommandList( xml, ContextNameList.EXIT, exceptionReporter );
		
		var stateTransitionVO 		= new StateTransitionVO( identifier, staticReference, instanceReference, enterList, exitList );
		stateTransitionVO.ifList 	= XMLParserUtil.getIfList( xml );
		stateTransitionVO.ifNotList = XMLParserUtil.getIfNotList( xml );
		
		stateTransitionVO.filePosition 	= exceptionReporter._positionTracker.makePositionFromNode( xml );
		XmlCompiler._assembler.configureStateTransition( applicationContext, stateTransitionVO );
	}
	
	static public function _getCommandList( xml : Xml, elementName : String, exceptionReporter : XmlAssemblingExceptionReporter ) : Array<CommandMappingVO>
	{
		var iterator = xml.elementsNamed( elementName );
		var list : Array<CommandMappingVO> = [];
		while( iterator.hasNext() )
		{
			var item = iterator.next();
			var commandClass = item.get( ContextAttributeList.COMMAND_CLASS );
			
			try
			{
				XmlCompiler._importHelper.forceCompilation( commandClass );
			}
			catch ( e : String )
			{
				exceptionReporter.throwMissingTypeException( commandClass, item, ContextAttributeList.COMMAND_CLASS );
			}

			var commandMappingVO 			= new CommandMappingVO( commandClass, item.get( ContextAttributeList.FIRE_ONCE ) == "true", item.get( ContextAttributeList.CONTEXT_OWNER ) );
			commandMappingVO.filePosition 	= exceptionReporter._positionTracker.makePositionFromNode( item );
			list.push( commandMappingVO );
		}
		
		return list;
	}
	
	static function getApplicationContext( doc : Xml176Document, exceptionReporter : XmlAssemblingExceptionReporter ) : ExprOf<AbstractApplicationContext>
	{
		var xml = doc.document.firstElement();
		
		var applicationContextClass = null;
		var applicationContextClassName : String = xml.get( ContextAttributeList.TYPE );
		
		if ( applicationContextClassName != null )
		{
			try
			{
				applicationContextClass = MacroUtil.getPack( applicationContextClassName );
			}
			catch ( error : Dynamic )
			{
				exceptionReporter.throwMissingTypeException( applicationContextClassName, xml, ContextAttributeList.TYPE );
			}
		}
		
		var applicationContextName : String = XmlCompiler.getRootApplicationContextName( xml, exceptionReporter );
		
		var expr;
		if ( applicationContextClass != null )
		{
			expr = macro @:mergeBlock { var applicationContext = applicationAssembler.getApplicationContext( $v { applicationContextName }, $p { applicationContextClass } ); };
		}
		else
		{
			expr = macro @:mergeBlock { var applicationContext = applicationAssembler.getApplicationContext( $v { applicationContextName } ); };
		}

		return expr;
	}
	
	static function getRootApplicationContextName( xml : Xml, exceptionReporter : XmlAssemblingExceptionReporter ) : String
	{
		var applicationContextName : String = xml.get( "name" );
		if ( applicationContextName == null )
		{
			exceptionReporter.throwMissingApplicationContextNameException( xml );
			return null;
		}
		else
		{
			return applicationContextName;
		}
	}
	#end
	
	macro public static function readXmlFile( fileName : String, ?m : Expr ) : ExprOf<ApplicationAssembler>
	{
		var r = XmlContextReader.readXmlFile( fileName, m );
		var xmlRawData = r.xrd;
		var xrdCollection = r.collection;
		var positionTracker : XmlPositionTracker;
		var exceptionReporter : XmlAssemblingExceptionReporter;
		var doc;
		
		try
		{
			doc = Xml176Parser.parse( xmlRawData.data, xmlRawData.path );
			exceptionReporter = new XmlAssemblingExceptionReporter( new XmlPositionTracker( doc, xrdCollection ) );
			XmlCompiler._importHelper = new ClassImportHelper();
			
			//
			XmlCompiler._assembler 		= new CompileTimeApplicationAssembler();
			var applicationContext 		= XmlCompiler._assembler.getApplicationContext( XmlCompiler.getRootApplicationContextName( doc.document.firstElement(), exceptionReporter ) );
			
			//States parsing
			var iterator = doc.document.firstElement().elementsNamed( "state" );
			while ( iterator.hasNext() )
			{
				var node = iterator.next();
				XmlCompiler._parseStateNodes( applicationContext, node, exceptionReporter );
				doc.document.firstElement().removeChild( node );
			}
			
			//DSL parsing
			iterator = doc.document.firstElement().elements();
			while ( iterator.hasNext() )
			{
				XmlCompiler._parseNode( applicationContext, iterator.next(), exceptionReporter );
			}

		}
		catch ( error : haxe.macro.Error )
		{
			Context.error( 'Xml parsing failed @$fileName $error', Context.currentPos() );
		}
		
		var assembler = XmlCompiler._assembler;

		//Create runtime applicationAssembler
		var applicationAssemblerTypePath = MacroUtil.getTypePath( Type.getClassName( ApplicationAssembler ) );
		assembler.addExpression( macro @:mergeBlock { var applicationAssembler = new $applicationAssemblerTypePath(); } );
		
		//Create runtime applicationContext
		assembler.addExpression( getApplicationContext( doc, exceptionReporter ) );
		
		//Dispatch CONTEXT_PARSED message
		var messageType = MacroUtil.getStaticVariable( "hex.ioc.assembler.ApplicationAssemblerMessage.CONTEXT_PARSED" );
		assembler.addExpression( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
		
		//Create applicationcontext injector
		assembler.addExpression( macro @:mergeBlock { var __applicationContextInjector = applicationContext.getInjector(); } );
			
		//Create runtime coreFactory
		assembler.addExpression( macro @:mergeBlock { var coreFactory = applicationContext.getCoreFactory(); } );
		
		//Create runtime AnnotationProvider
		assembler.addExpression( macro @:mergeBlock { var __annotationProvider = applicationContext.getCoreFactory().getAnnotationProvider(); } );

		//build
		XmlCompiler._assembler.buildEverything();
		
		//return program
		assembler.addExpression( macro { applicationAssembler; } );
		return assembler.getMainExpression();
	}
}
