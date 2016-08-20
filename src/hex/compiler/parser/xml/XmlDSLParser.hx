package hex.compiler.parser.xml;

#if macro
import com.tenderowls.xml176.Xml176Parser;
import hex.ioc.assembler.ConditionalVariablesChecker;
import haxe.macro.Expr;
import hex.compiler.parser.preprocess.MacroPreprocessor;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.parser.xml.XMLParserUtil;
import haxe.macro.Context;

/**
 * ...
 * @author Francis Bourre
 */
class XmlDSLParser
{
	static public function parse( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariablesChecker : ConditionalVariablesChecker ) : Xml
	{
		Xml176Parser.init();
		var xml = Xml.parse( '<root/>' );
		XmlDSLParser._processFile( xml, fileName, true, preprocessingVariables, conditionalVariablesChecker );
		return xml;
	}
	
	static function _processFile( finalXML: Xml, fileName: String, isRoot : Bool, ?preprocessingVariables: Expr, ?conditionalVariablesChecker: ConditionalVariablesChecker )
	{
		var finalRootXML = finalXML.firstElement();
	
		//read file
		var dsl = XmlDSLParser._readFile( fileName );
		
		//preprocess
		dsl.data = MacroPreprocessor.parse( dsl.data, preprocessingVariables );
		
		//xml building
		var rootXml = Xml176Parser.parse( dsl.data, dsl.path ).firstElement();
		
		if ( isRoot )
		{
			for ( att in rootXml.attributes() ) 
			{
				finalRootXML.set( att, rootXml.get( att ) );
			}
		}
		
		//collect include nodes
		var includeList : Array<Xml> = XmlDSLParser._getIncludeList( rootXml, conditionalVariablesChecker );
		
		//parse/remove comditionals
		var iterator = rootXml.elements();
		while ( iterator.hasNext() )
		{
			var node : Xml = iterator.next();
			if ( XmlDSLParser._isIncludeAllowed( node, conditionalVariablesChecker ) )
			{
				finalRootXML.addChild( node );
			}
		}
		
		//parse include collection
		for ( include in includeList )
		{
			var fileName = include.get( ContextAttributeList.FILE );
			XmlDSLParser._processFile( finalXML, fileName, false, preprocessingVariables, conditionalVariablesChecker );
		}
	}
	
	static function _getIncludeList( root : Xml, ?conditionalVariablesChecker: ConditionalVariablesChecker ) : Array<Xml>
	{
		var includeList : Array<Xml> = [];
		var includes = root.elementsNamed( "include" );
		while ( includes.hasNext() )
		{
			var node : Xml = includes.next();
			if ( XmlDSLParser._isIncludeAllowed( node, conditionalVariablesChecker ) )
			{
				includeList.push( node );
			}

			root.removeChild( node );
		}

		return includeList;
	}
	
	static function _isIncludeAllowed( node : Xml, ?conditionalVariablesChecker : ConditionalVariablesChecker ) : Bool
	{
		if ( conditionalVariablesChecker != null )
		{
			var ifList 				= XMLParserUtil.getIfList( node );
			var ifNotList 			= XMLParserUtil.getIfNotList( node );

			if ( conditionalVariablesChecker.allowsIfList( ifList ) && conditionalVariablesChecker.allowsIfNotList( ifNotList ) )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else 
		{
			return true;
		}
	}
	
	static function _readFile( fileName : String, ?preprocessingVariables : Expr ) : XmlDSLData
	{
		try
		{
			//resolve
			var path = Context.resolvePath( fileName );
			Context.registerModuleDependency( Context.getLocalModule(), path );
			
			//read data
			var data = sys.io.File.getContent( path );
			
			//instantiate XmlDSLData result
			var result = 	{ 	
								data: 				data,
								length: 			data.length, 
								path: 				path,
							};
			
			return result;
		}
		catch ( error : Dynamic )
		{
			return Context.error( 'File loading failed @$fileName $error', Context.currentPos() );
		}
	}
}
#end