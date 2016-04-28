package hex.compiler.parser.xml;

import com.tenderowls.xml176.Xml176Parser;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.ApplicationAssembler;
import hex.compiler.assembler.CompileTimeApplicationAssembler;
import hex.compiler.core.CompileTimeCoreFactory;
import hex.ioc.core.ContextAttributeList;
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.ioc.core.ContextNameList;
import hex.ioc.core.ContextTypeList;
import hex.ioc.parser.xml.XMLAttributeUtil;
import hex.ioc.parser.xml.XMLParserUtil;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVOArguments;
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
			XmlCompiler._assembler.buildObject( applicationContext, identifier, type, args, factory );
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
				type = staticRef != null ? ContextTypeList.INSTANCE : ContextTypeList.STRING;
			}

			if ( type == ContextTypeList.HASHMAP || type == ContextTypeList.SERVICE_LOCATOR )
			{
				args = XMLParserUtil.getMapArguments( identifier, xml );
				for ( arg in args )
				{
					if ( arg.key != null )
						XmlCompiler._importHelper.includeClass( arg.key );
					
					if ( arg.value != null )
						XmlCompiler._importHelper.includeClass( arg.value );
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
				XmlCompiler._importHelper.forceCompilation( type );
			}
			catch ( e : String )
			{
				Context.error( "XmlCompiler parsing error with '" + xml.nodeName + "' node, '" + type + "' type not found.", positionTracker.makePositionFromAttribute( xml, ContextAttributeList.TYPE ) );
			}
			
			XmlCompiler._importHelper.forceCompilation( mapType );
			XmlCompiler._importHelper.includeStaticRef( staticRef );
			
			XmlCompiler._assembler.buildObject( applicationContext, identifier, type, args, factory, singleton, injectInto, mapType, staticRef, ifList, ifNotList );

			// Build property.
			var propertyIterator = xml.elementsNamed( ContextNameList.PROPERTY );
			while ( propertyIterator.hasNext() )
			{
				var property = propertyIterator.next();
				XmlCompiler._importHelper.includeStaticRef( property.get( ContextAttributeList.STATIC_REF ) );
				
				XmlCompiler._assembler.buildProperty (
						applicationContext,
						identifier,
						XMLAttributeUtil.getName( property ),
						XMLAttributeUtil.getValue( property ),
						XMLAttributeUtil.getType( property ),
						XMLAttributeUtil.getRef( property ),
						XMLAttributeUtil.getMethod( property ),
						XMLAttributeUtil.getStaticRef( property ),
						XMLParserUtil.getIfList( xml ),
						XMLParserUtil.getIfNotList( xml )
				);
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
				
				XmlCompiler._assembler.buildMethodCall( applicationContext, identifier, xml.get( ContextAttributeList.NAME ), XMLParserUtil.getMethodCallArguments( identifier, methodCallItem ), XMLParserUtil.getIfList( methodCallItem ), XMLParserUtil.getIfNotList( methodCallItem ) );
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
					
					XmlCompiler._assembler.buildDomainListener( applicationContext, identifier, channelName, listenerArgs, XMLParserUtil.getIfList( listener ), XMLParserUtil.getIfNotList( listener ) );
				}
				else
				{
					Context.error( "XmlCompiler parsing error with '" + xml.nodeName + "' node, 'ref' attribute is mandatory in a 'listen' node.", positionTracker.makePositionFromNode( listener ) );
				}
			}
		}
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
			expr = macro @:mergeBlock { var applicationContext = applicationAssembler.getApplicationContext( $v{ applicationContextName }, $p { applicationContextClass } ); };
		}
		else
		{
			expr = macro @:mergeBlock { var applicationContext = applicationAssembler.getApplicationContext( $v{ applicationContextName } ); };
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
			
			//
			var iterator = doc.document.firstElement().elements();
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
		
		//Create runtime coreFactory
		assembler.addExpression( macro @:mergeBlock { var coreFactory = applicationContext.getCoreFactory(); } );

		//build
		XmlCompiler._assembler.buildEverything();
		
		//return program
		assembler.addExpression( macro { applicationAssembler; } );
		return assembler.getMainExpression();
	}
}
