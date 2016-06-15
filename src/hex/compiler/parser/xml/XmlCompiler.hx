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
			factory = xml.get( ContextAttributeList.PARSER_CLASS );
			args = [ new ConstructorVO( identifier, ContextTypeList.STRING, [ xml.firstElement().toString() ] ) ];
			
			var constructorVO 		= new ConstructorVO( identifier, type, args, factory );
			constructorVO.ifList 	= XMLParserUtil.getIfList( xml );
			constructorVO.ifNotList = XMLParserUtil.getIfNotList( xml );

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
				args = XMLParserUtil.getMapArguments( identifier, xml );
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
						
						if ( arg.staticRef != null )
						{
							var type = ClassImportHelper.getClassFullyQualifiedNameFromStaticRef( arg.staticRef );
							try 
							{
								XmlCompiler._importHelper.forceCompilation( type );
								
							} catch ( e : String ) 
							{
								exceptionReporter.throwStaticRefNotFoundException( type.length > 0 ? type : arg.staticRef, node );
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
									exceptionReporter.throwClassNotFoundException( arg.arguments[ 0 ], node );
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
					exceptionReporter.throwTypeNotFoundException( type, xml );
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
					exceptionReporter.throwStaticRefNotFoundException( t, xml );
				}
			}
			
			try
			{
				XmlCompiler._importHelper.forceCompilation( mapType );
			}
			catch ( e : String )
			{
				exceptionReporter.throwMappedTypeNotFoundException( mapType, xml );
			}
			
			try
			{
				XmlCompiler._importHelper.includeStaticRef( staticRef );
			}
			catch ( e : String )
			{
				exceptionReporter.throwStaticRefNotFoundException( staticRef, xml );
			}
			
			if ( type == ContextTypeList.CLASS )
			{
				XmlCompiler._importHelper.forceCompilation( args[ 0 ].arguments[ 0 ] );
			}
			
			var constructorVO 		= new ConstructorVO( identifier, type, args, factory, singleton, injectInto, null, mapType, staticRef );
			constructorVO.ifList 	= ifList;
			constructorVO.ifNotList = ifNotList;

			exceptionReporter.register( constructorVO, xml );
			constructorVO.exceptionReporter = exceptionReporter;
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
						exceptionReporter.throwStaticRefNotFoundException( type, property );
					}
				}
				
				var propertyVO = new PropertyVO ( 	identifier, 
													XMLAttributeUtil.getName( property ),
													XMLAttributeUtil.getValue( property ),
													XMLAttributeUtil.getType( property ),
													XMLAttributeUtil.getRef( property ),
													XMLAttributeUtil.getMethod( property ),
													XMLAttributeUtil.getStaticRef( property ) );
				
				propertyVO.ifList = XMLParserUtil.getIfList( xml );
				propertyVO.ifNotList = XMLParserUtil.getIfNotList( xml );
				
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
					var node = iterator.next();
					var arg = XMLParserUtil._getConstructorVOFromXML( identifier, node );
					
					if ( arg.staticRef != null )
					{
						var type = ClassImportHelper.getClassFullyQualifiedNameFromStaticRef( arg.staticRef );
						try 
						{
							var type = ClassImportHelper.getClassFullyQualifiedNameFromStaticRef( staticRef );
							XmlCompiler._importHelper.forceCompilation( type );
							
						} catch ( e : String ) 
						{
							exceptionReporter.throwStaticRefNotFoundException( type.length > 0 ? type : arg.staticRef, node );
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
								exceptionReporter.throwClassNotFoundException( arg.arguments[ 0 ], node );
							}
						}
					}
					args.push( arg );
				}
				
				var methodCallVO 		= new MethodCallVO( identifier, methodCallItem.get( ContextAttributeList.NAME ), XMLParserUtil.getMethodCallArguments( identifier, methodCallItem ) );
				methodCallVO.ifList 	= XMLParserUtil.getIfList( methodCallItem );
				methodCallVO.ifNotList 	= XMLParserUtil.getIfNotList( methodCallItem );
				
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
								exceptionReporter.throwStaticRefNotFoundException( type, node );
							}
						}
						
						try
						{
							XmlCompiler._importHelper.forceCompilation( listenerArg.strategy );
						}
						catch ( e : String )
						{
							exceptionReporter.throwStrategyNotFoundException( listenerArg.strategy, node );
						}

						listenerArgs.push( listenerArg );
					}

					var domainListenerVO 		= new DomainListenerVO( identifier, channelName, listenerArgs );
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
	
	static function _parseStateNodes( applicationContext : AbstractApplicationContext, xml : Xml, exceptionReporter : XmlAssemblingExceptionReporter ) : Void
	{
		var identifier : String = xml.get( ContextAttributeList.ID );
		if ( identifier == null )
		{
			exceptionReporter.throwMissingIDException( xml );
		}
		
		var staticReference 	: String = xml.get( ContextAttributeList.STATIC_REF );
		var instanceReference 	: String = xml.get( ContextAttributeList.REF );
		
		// Build enter list
		var enterListIterator = xml.elementsNamed( ContextNameList.ENTER );
		var enterList : Array<CommandMappingVO> = [];
		while( enterListIterator.hasNext() )
		{
			var enterListItem = enterListIterator.next();
			var commandClass = enterListItem.get( ContextAttributeList.COMMAND_CLASS );
			
			try
			{
				XmlCompiler._importHelper.forceCompilation( commandClass );
			}
			catch ( e : String )
			{
				exceptionReporter.throwCommandClassNotFoundException( commandClass, enterListItem );
			}

			enterList.push( new CommandMappingVO( commandClass, enterListItem.get( ContextAttributeList.FIRE_ONCE ) == "true", enterListItem.get( ContextAttributeList.CONTEXT_OWNER ) ) );
		}
		
		// Build exit list
		var exitListIterator = xml.elementsNamed( ContextNameList.EXIT );
		var exitList : Array<CommandMappingVO> = [];
		while( exitListIterator.hasNext() )
		{
			var exitListItem = exitListIterator.next();
			var commandClass = exitListItem.get( ContextAttributeList.COMMAND_CLASS );
			
			try
			{
				XmlCompiler._importHelper.forceCompilation( commandClass );
			}
			catch ( e : String )
			{
				exceptionReporter.throwCommandClassNotFoundException( commandClass, exitListItem );
			}

			XmlCompiler._importHelper.forceCompilation( exitListItem.get( ContextAttributeList.COMMAND_CLASS ) );
			exitList.push( new CommandMappingVO( commandClass, exitListItem.get( ContextAttributeList.FIRE_ONCE ) == "true", exitListItem.get( ContextAttributeList.CONTEXT_OWNER ) ) );
		}
		
		var stateTransitionVO 		= new StateTransitionVO( identifier, staticReference, instanceReference, enterList, exitList );
		stateTransitionVO.ifList 	= XMLParserUtil.getIfList( xml );
		stateTransitionVO.ifNotList = XMLParserUtil.getIfNotList( xml );
		
		XmlCompiler._assembler.configureStateTransition( applicationContext, stateTransitionVO );
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
				exceptionReporter.throwTypeNotFoundException( applicationContextClassName, xml );
			}
		}
		
		var applicationContextName : String = xml.get( "name" );
		if ( applicationContextName == null )
		{
			exceptionReporter.throwMissingApplicationContextNameException( xml );
		}
		
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
			var applicationContext 		= XmlCompiler._assembler.getApplicationContext( "name" );
			
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
