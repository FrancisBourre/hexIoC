package hex.ioc.parser.xml;


#if macro
import haxe.macro.Context;
import hex.compiler.parser.xml.IPositionTracker;
import hex.ioc.error.IAssemblingExceptionReporter;
import hex.ioc.vo.AssemblerVO;
import haxe.macro.Expr.Position;

/**
 * ...
 * @author Francis Bourre
 */
class XmlAssemblingExceptionReporter implements IAssemblingExceptionReporter<Xml>
{
	var _map : Map<AssemblerVO, Xml>;
	var _positionTracker ( default, null ) : IPositionTracker;

	public function new( positionTracker : IPositionTracker ) 
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
	
	public function getPosition( xml : Xml, ?additionalInformations : Dynamic ) : Position
	{
		return additionalInformations == null ? this._positionTracker.makePositionFromNode( xml ) : this._positionTracker.makePositionFromAttribute( xml, additionalInformations );
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