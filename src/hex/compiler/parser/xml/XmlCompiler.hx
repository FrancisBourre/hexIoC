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
import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;
import hex.ioc.vo.StateTransitionVO;
import hex.util.ClassUtil;
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
	static function _parseNode( applicationContext : AbstractApplicationContext, xml : Xml, positionTracker : XmlPositionTracker ) : Void
	{
		var identifier : String = xml.get( ContextAttributeList.ID );
		if ( identifier == null )
		{
			Context.error( "XmlCompiler parsing error with '" + xml.nodeName + "' node, 'id' attribute not found.", positionTracker.makePositionFromNode( xml ) );
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
				args = XMLParserUtil.getArguments( identifier, xml, type );
				for ( arg in args )
				{
					if ( !XmlCompiler._importHelper.includeStaticRef( arg.staticRef ) )
					{
						XmlCompiler._importHelper.includeClass( arg );
					}
				}
			}

			try
			{
				if ( type != ContextTypeList.STATIC_VARIABLE )
				{
					XmlCompiler._importHelper.forceCompilation( type );
				}
				else
				{
					var t = ClassUtil.getClassNameFromStaticReference( staticRef );
					XmlCompiler._importHelper.forceCompilation( t );
				}
				
			}
			catch ( e : String )
			{
				Context.error( "XmlCompiler parsing error with '" + xml.nodeName + "' node, '" + type + "' type not found.", positionTracker.makePositionFromAttribute( xml, ContextAttributeList.TYPE ) );
			}
			
			XmlCompiler._importHelper.forceCompilation( mapType );
			XmlCompiler._importHelper.includeStaticRef( staticRef );
			
			if ( type == ContextTypeList.CLASS )
			{
				XmlCompiler._importHelper.forceCompilation( args[ 0 ].arguments[ 0 ] );
			}
			
			var constructorVO 		= new ConstructorVO( identifier, type, args, factory, singleton, injectInto, null, mapType, staticRef );
			constructorVO.ifList 	= ifList;
			constructorVO.ifNotList = ifNotList;

			XmlCompiler._assembler.buildObject( applicationContext, constructorVO );

			// Build property.
			var propertyIterator = xml.elementsNamed( ContextNameList.PROPERTY );
			while ( propertyIterator.hasNext() )
			{
				var property = propertyIterator.next();
				XmlCompiler._importHelper.includeStaticRef( property.get( ContextAttributeList.STATIC_REF ) );
				
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

				args = XMLParserUtil.getMethodCallArguments( identifier, methodCallItem );
				for ( arg in args )
				{
					if ( !XmlCompiler._importHelper.includeStaticRef( arg.staticRef ) )
					{
						XmlCompiler._importHelper.includeClass( arg );
					}
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
					var listenerArgs : Array<DomainListenerVOArguments> = XMLParserUtil.getEventArguments( listener );
					for ( listenerArg in listenerArgs )
					{
						XmlCompiler._importHelper.includeStaticRef( listenerArg.staticRef );
						XmlCompiler._importHelper.forceCompilation( listenerArg.strategy );
					}
					
					var domainListenerVO 		= new DomainListenerVO( identifier, channelName, listenerArgs );
					domainListenerVO.ifList 	= XMLParserUtil.getIfList( listener );
					domainListenerVO.ifNotList 	= XMLParserUtil.getIfNotList( listener );
					
					XmlCompiler._assembler.buildDomainListener( applicationContext, domainListenerVO );
				}
				else
				{
					Context.error( "XmlCompiler parsing error with '" + xml.nodeName + "' node, 'ref' attribute is mandatory in a 'listen' node.", positionTracker.makePositionFromNode( listener ) );
				}
			}
		}
	}
	
	static function _parseStateNodes( applicationContext : AbstractApplicationContext, xml : Xml, positionTracker : XmlPositionTracker ) : Void
	{
		var identifier : String = xml.get( ContextAttributeList.ID );
		if ( identifier == null )
		{
			Context.error( "XmlCompiler parsing error with '" + xml.nodeName + "' node, 'id' attribute not found.", positionTracker.makePositionFromNode( xml ) );
		}
		
		var staticReference 	: String = xml.get( ContextAttributeList.STATIC_REF );
		var instanceReference 	: String = xml.get( ContextAttributeList.REF );
		
		// Build enter list
		var enterListIterator = xml.elementsNamed( ContextNameList.ENTER );
		var enterList : Array<CommandMappingVO> = [];
		while( enterListIterator.hasNext() )
		{
			var enterListItem = enterListIterator.next();
			enterList.push( new CommandMappingVO( enterListItem.get( ContextAttributeList.COMMAND_CLASS ), enterListItem.get( ContextAttributeList.FIRE_ONCE ) == "true", enterListItem.get( ContextAttributeList.CONTEXT_OWNER ) ) );
		}
		
		// Build exit list
		var exitListIterator = xml.elementsNamed( ContextNameList.EXIT );
		var exitList : Array<CommandMappingVO> = [];
		while( exitListIterator.hasNext() )
		{
			var exitListItem = exitListIterator.next();
			exitList.push( new CommandMappingVO( exitListItem.get( ContextAttributeList.COMMAND_CLASS ), exitListItem.get( ContextAttributeList.FIRE_ONCE ) == "true", exitListItem.get( ContextAttributeList.CONTEXT_OWNER ) ) );
		}
		
		var stateTransitionVO 		= new StateTransitionVO( identifier, staticReference, instanceReference, enterList, exitList );
		stateTransitionVO.ifList 	= XMLParserUtil.getIfList( xml );
		stateTransitionVO.ifNotList = XMLParserUtil.getIfNotList( xml );
		
		XmlCompiler._assembler.configureStateTransition( applicationContext, stateTransitionVO );
	}
	
	static function getApplicationContext( doc : Xml176Document, positionTracker : XmlPositionTracker ) : ExprOf<AbstractApplicationContext>
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
				Context.error( "XmlCompiler failed to instantiate applicationContext class typed '" + applicationContextClassName + "'", positionTracker.makePositionFromAttribute( xml, ContextAttributeList.TYPE ) );
			}
		}
		
		var applicationContextName : String = xml.get( "name" );
		if ( applicationContextName == null )
		{
			Context.error( "XmlCompiler failed to retrieve applicationContext name. You should add 'name' attribute to the root of your xml context", positionTracker.makePositionFromNode( xml  ) );
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
		var doc;
		
		try
		{
			doc = Xml176Parser.parse( xmlRawData.data, xmlRawData.path );
			positionTracker = new XmlPositionTracker( doc, xrdCollection );
			XmlCompiler._importHelper = new ClassImportHelper();
			
			//
			XmlCompiler._assembler 		= new CompileTimeApplicationAssembler();
			var applicationContext 		= XmlCompiler._assembler.getApplicationContext( "name" );
			
			//States parsing
			var iterator = doc.document.firstElement().elementsNamed( "state" );
			while ( iterator.hasNext() )
			{
				var node = iterator.next();
				XmlCompiler._parseStateNodes( applicationContext, node, positionTracker );
				doc.document.firstElement().removeChild( node );
			}
			
			//DSL parsing
			iterator = doc.document.firstElement().elements();
			while ( iterator.hasNext() )
			{
				XmlCompiler._parseNode( applicationContext, iterator.next(), positionTracker );
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
		assembler.addExpression( getApplicationContext( doc, positionTracker ) );
		
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
