package hex.ioc.parser.xml;

import hex.core.IApplicationAssembler;
import hex.util.MacroUtil;

#if macro
import haxe.macro.Context;
import hex.preprocess.MacroConditionalVariablesProcessor;
import hex.compiletime.util.ClassImportHelper;
import hex.preprocess.ConditionalVariablesChecker;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.core.ContextNameList;
import hex.core.ContextTypeList;
import hex.ioc.vo.DomainListenerVOArguments;
import haxe.macro.Expr;
import hex.compiletime.xml.IXmlPositionTracker;
import hex.compiletime.xml.PositionTracker;
import hex.compiletime.xml.DSLReader;

using StringTools;
#end

/**
 * ...
 * @author Francis Bourre
 */
class XmlReader
{
	#if macro
	static var _importHelper : ClassImportHelper;
	
	static function _parseNode( xml : Xml, positionTracker : IXmlPositionTracker ) : Void
	{
		var shouldConstruct = true;
	
		var identifier : String = xml.get( ContextAttributeList.ID );
		if ( identifier == null )
		{
			identifier = XMLAttributeUtil.getRef( xml );
			if ( identifier != null )
			{
				shouldConstruct = false;
			}
			else
			{
				Context.error( "XmlReader parsing error with '" + xml.nodeName + "' node, 'id' attribute not found.", positionTracker.makePositionFromNode( xml ) );
			}
		}

		var type 		: String;
		var args 		: Array<Dynamic>;
		var mapType		: String;
		var staticRef	: String;

		// Build object.
		type = xml.get( ContextAttributeList.TYPE );

		if ( type == ContextTypeList.XML )
		{
			XmlReader._importHelper.forceCompilation( xml.get( ContextAttributeList.PARSER_CLASS ) );
		}
		else
		{
			var strippedType = type != null ? type.split( '<' )[ 0 ] : type;
			if ( strippedType == ContextTypeList.HASHMAP || strippedType == ContextTypeList.MAPPING_CONFIG )
			{
				args = XMLParserUtil.getMapArguments( identifier, xml );
				for ( arg in args )
				{
					if ( arg.getPropertyKey() != null )
					{
						if ( arg.getPropertyKey().type == ContextTypeList.CLASS )
						{
							XmlReader._importHelper.forceCompilation( arg.getPropertyKey().arguments[0] );
						}
					}
					
					if ( arg.getPropertyValue() != null )
					{
						if ( arg.getPropertyValue().type == ContextTypeList.CLASS )
						{
							XmlReader._importHelper.forceCompilation( arg.getPropertyValue().arguments[0] );
						}
					}
				}
			}
			else
			{
				args = XMLParserUtil.getArguments( identifier, xml, type );
				for ( arg in args )
				{
					if ( !XmlReader._importHelper.includeStaticRef( arg.staticRef ) )
					{
						XmlReader._importHelper.includeClass( arg );
					}
				}
			}

			try
			{
				XmlReader._importHelper.forceCompilation( type );
			}
			catch ( e : String )
			{
				Context.error( "XmlReader parsing error with '" + xml.nodeName + "' node, '" + type + "' type not found.", positionTracker.makePositionFromAttribute( xml, ContextAttributeList.TYPE ) );
			}
			
			//map-type
			var mapTypes = XMLParserUtil.getMapType( xml );
			if ( mapTypes != null )
			{
				for ( mapType in mapTypes )
				{
					XmlReader._importHelper.forceCompilation( mapType.split( '<' )[ 0 ] );
				}
			}
	
			if ( xml.get( ContextAttributeList.FACTORY_METHOD ) == null ) 
			{
				XmlReader._importHelper.includeStaticRef( xml.get( ContextAttributeList.STATIC_REF ) );
			}
			
			if ( type == ContextTypeList.CLASS )
			{
				XmlReader._importHelper.forceCompilation( args[ 0 ] );
			}

			// Build property.
			var propertyIterator = xml.elementsNamed( ContextNameList.PROPERTY );
			while ( propertyIterator.hasNext() )
			{
				XmlReader._importHelper.includeStaticRef( propertyIterator.next().get( ContextAttributeList.STATIC_REF ) );
			}

			// Build method call.
			var methodCallIterator = xml.elementsNamed( ContextNameList.METHOD_CALL );
			while( methodCallIterator.hasNext() )
			{
				var methodCallItem = methodCallIterator.next();

				args = XMLParserUtil.getMethodCallArguments( identifier, methodCallItem );
				for ( arg in args )
				{
					if ( !XmlReader._importHelper.includeStaticRef( arg.staticRef ) )
					{
						XmlReader._importHelper.includeClass( arg );
					}
					else if ( arg.type == ContextTypeList.CLASS )
					{
						XmlReader._importHelper.forceCompilation( arg.value );
					}
					else if( arg.staticRef != null )
					{
						XmlReader._importHelper.includeStaticRef( arg.staticRef );
					}
				}
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
						XmlReader._importHelper.includeStaticRef( listenerArg.staticRef );
						XmlReader._importHelper.forceCompilation( listenerArg.strategy );
					}
				}
				else
				{
					Context.error( "XmlReader parsing error with '" + xml.nodeName + "' node, 'ref' attribute is mandatory in a 'listen' node.", positionTracker.makePositionFromNode( listener ) );
				}
			}
		}
	}
	
	static function _parseStateNodes( xml : Xml, positionTracker : IXmlPositionTracker ) : Void
	{
		var identifier : String = xml.get( ContextAttributeList.ID );
		if ( identifier == null )
		{
			Context.error( "XmlReader parsing error with '" + xml.nodeName + "' node, 'id' attribute not found.", positionTracker.makePositionFromNode( xml ) );
		}
		
		var staticReference 	: String = xml.get( ContextAttributeList.STATIC_REF );
		var instanceReference 	: String = xml.get( ContextAttributeList.REF );
		
		// Build enter list
		var enterListIterator = xml.elementsNamed( ContextNameList.ENTER );

		while( enterListIterator.hasNext() )
		{
			var enterListItem = enterListIterator.next();
			XmlReader._importHelper.forceCompilation( enterListItem.get( ContextAttributeList.COMMAND_CLASS ) );
		}
		
		// Build exit list
		var exitListIterator = xml.elementsNamed( ContextNameList.EXIT );

		while( exitListIterator.hasNext() )
		{
			var exitListItem = exitListIterator.next();
			XmlReader._importHelper.forceCompilation( exitListItem.get( ContextAttributeList.COMMAND_CLASS ) );
		}
	}
	
	static function _readXmlFile( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr ) : ExprOf<String>
	{
		var conditionalVariablesMap 	= MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		
		var reader						= new DSLReader();
		var document 					= reader.read( fileName, preprocessingVariables, conditionalVariablesChecker );
		var data 						= document.toString();
		
		XmlReader._importHelper 		= new ClassImportHelper();

		//States parsing
		var iterator = document.firstElement().elementsNamed( "state" );
		while ( iterator.hasNext() )
		{
			var node = iterator.next();
			XmlReader._parseStateNodes( node, reader.positionTracker );
			document.firstElement().removeChild( node );
		}
		
		//DSL parsing
		var iterator = document.firstElement().elements();
		while ( iterator.hasNext() )
		{
			XmlReader._parseNode( iterator.next(), reader.positionTracker );
		}
		
		return macro $v{ data };
	}
	#end
	
	macro public static function getXmlFileContent( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr ) : ExprOf<String>
	{
		return XmlReader._readXmlFile( fileName, preprocessingVariables, conditionalVariables );
	}
	
	macro public static function getXml( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr ) : ExprOf<Xml>
	{
		var tp = MacroUtil.getPack( Type.getClassName( Xml ) );
		var data = XmlReader._readXmlFile( fileName, preprocessingVariables, conditionalVariables );
		return macro @:pos( Context.currentPos() ){ $p { tp }.parse( $data ); }
	}
	
	macro public static function read( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr ) : ExprOf<IApplicationAssembler>
	{
		var xmlPack = MacroUtil.getPack( Type.getClassName( Xml ) );
		var applicationAssemblerTypePath = MacroUtil.getTypePath( "hex.runtime.ApplicationAssembler" );
		var applicationXMLParserTypePath = MacroUtil.getTypePath( Type.getClassName( ApplicationXMLParser ) );
		var data = XmlReader._readXmlFile( fileName, preprocessingVariables, conditionalVariables );
		
		return macro @:pos( Context.currentPos() )
		{ 
			var applicationAssembler = new $applicationAssemblerTypePath(); 
			var applicationXmlParser = new $applicationXMLParserTypePath();
			applicationXmlParser.parse( applicationAssembler, $p { xmlPack }.parse( $data ) );
			applicationAssembler; 
		}
	}
}