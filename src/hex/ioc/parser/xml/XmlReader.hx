package hex.ioc.parser.xml;

import com.tenderowls.xml176.Xml176Parser;
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.compiler.parser.preprocess.MacroConditionalVariablesProcessor;
import hex.compiler.parser.xml.ClassImportHelper;
import hex.compiler.parser.xml.XmlContextReader;
import hex.compiler.parser.xml.XmlPositionTracker;
import hex.ioc.assembler.ConditionalVariablesChecker;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.core.ContextNameList;
import hex.ioc.core.ContextTypeList;
import hex.ioc.vo.DomainListenerVOArguments;

using StringTools;

/**
 * ...
 * @author Francis Bourre
 */
class XmlReader
{
	static var _importHelper : ClassImportHelper;
	
	#if macro
	static function _parseNode( xml : Xml, positionTracker : XmlPositionTracker ) : Void
	{
		var identifier : String = xml.get( ContextAttributeList.ID );
		if ( identifier == null )
		{
			Context.error( "XmlReader parsing error with '" + xml.nodeName + "' node, 'id' attribute not found.", positionTracker.makePositionFromNode( xml ) );
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
			if ( type == ContextTypeList.HASHMAP || type == ContextTypeList.SERVICE_LOCATOR || type == ContextTypeList.MAPPING_CONFIG )
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
			
			XmlReader._importHelper.forceCompilation( xml.get( ContextAttributeList.MAP_TYPE ) );
			XmlReader._importHelper.includeStaticRef( xml.get( ContextAttributeList.STATIC_REF ) );
			
			if ( type == ContextTypeList.CLASS )
			{
				XmlReader._importHelper.forceCompilation( args[ 0 ].arguments[ 0 ] );
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
	
	static function _parseStateNodes( xml : Xml, positionTracker : XmlPositionTracker ) : Void
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
	#end
	
	macro public static function readXmlFile( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr ) : ExprOf<String>
	{
		var conditionalVariablesMap = MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		
		var r = XmlContextReader.readXmlFile( fileName, preprocessingVariables, conditionalVariablesChecker );
		var xmlRawData = r.xrd;
		var xrdCollection = r.collection;

		try
		{
			var doc = Xml176Parser.parse( xmlRawData.data, xmlRawData.path );
			var positionTracker = new XmlPositionTracker( doc, xrdCollection );
			XmlReader._importHelper = new ClassImportHelper();

			//States parsing
			var iterator = doc.document.firstElement().elementsNamed( "state" );
			while ( iterator.hasNext() )
			{
				var node = iterator.next();
				XmlReader._parseStateNodes( node, positionTracker );
				doc.document.firstElement().removeChild( node );
			}
			
			//DSL parsing
			var iterator = doc.document.firstElement().elements();
			while ( iterator.hasNext() )
			{
				XmlReader._parseNode( iterator.next(), positionTracker );
			}

		}
		catch ( error : haxe.macro.Error )
		{
			Context.error( 'Xml parsing failed @$fileName $error', Context.currentPos() );
		}

		return macro $v{ xmlRawData.data };
	}
}