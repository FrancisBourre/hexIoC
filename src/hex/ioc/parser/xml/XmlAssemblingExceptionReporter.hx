package hex.ioc.parser.xml;

#if macro
import haxe.macro.Context;
import hex.compiler.parser.xml.IXmlPositionTracker;
import hex.ioc.error.IAssemblingExceptionReporter;
import hex.ioc.vo.AssemblerVO;

/**
 * ...
 * @author Francis Bourre
 */
class XmlAssemblingExceptionReporter implements IAssemblingExceptionReporter
{
	var _map : Map<AssemblerVO, Xml>;
	public var _positionTracker ( default, null ) : IXmlPositionTracker;

	public function new( positionTracker : IXmlPositionTracker ) 
	{
		this._map = new Map();
		this._positionTracker = positionTracker;
	}
	
	public function throwMissingIDException( xml : Xml ) : Void 
	{
		Context.error( "Parsing error with '" + xml.nodeName + "' node, 'id' attribute not found.", this._positionTracker.makePositionFromNode( xml) );
	}
	
	public function throwMissingListeningReferenceException( parentNode : Xml, listenNode : Xml ) : Void
	{
		Context.error( "Parsing error with '" + parentNode.nodeName + "' node, 'ref' attribute is mandatory in a 'listen' node.", this._positionTracker.makePositionFromNode( listenNode ) );
	}
	
	public function throwMissingApplicationContextNameException( xml : Xml ) : Void
	{
		Context.error( "Fails to retrieve applicationContext name. You should add 'name' attribute to the root of your xml context", this._positionTracker.makePositionFromNode( xml  ) );
	}
	
	public function register( assemblerVO : AssemblerVO, xml : Xml ) : AssemblerVO
	{
		this._map.set( assemblerVO, xml );
		return assemblerVO;
	}
	
	//
	public function throwMissingTypeException( type : String, xml : Xml, attributeName : String ) : Void 
	{
		Context.error( "Type not found '" + type + "' ", this._positionTracker.makePositionFromAttribute( xml, attributeName ) );
	}
	
	//
	private function _getXML( vo : AssemblerVO ) : Xml
	{
		return this._map.get( vo );
	}
}
#end