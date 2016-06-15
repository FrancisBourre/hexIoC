package hex.ioc.parser.xml;

import haxe.macro.Context;
import hex.compiler.parser.xml.XmlPositionTracker;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.error.IAssemblingExceptionReporter;
import hex.ioc.vo.AssemblerVO;

/**
 * ...
 * @author Francis Bourre
 */
class XmlAssemblingExceptionReporter implements IAssemblingExceptionReporter
{
	var _map : Map<AssemblerVO, Xml>;
	var _positionTracker : XmlPositionTracker;

	public function new( positionTracker : XmlPositionTracker ) 
	{
		this._map = new Map();
		this._positionTracker = positionTracker;
	}
	
	public function throwMissingIDException( xml : Xml ) : Void 
	{
		#if macro
		Context.error( "Parsing error with '" + xml.nodeName + "' node, 'id' attribute not found.", this._positionTracker.makePositionFromNode( xml) );
		#end
	}
	
	public function throwMissingListeningReferenceException( parentNode : Xml, listenNode : Xml ) : Void
	{
		#if macro
		Context.error( "Parsing error with '" + parentNode.nodeName + "' node, 'ref' attribute is mandatory in a 'listen' node.", this._positionTracker.makePositionFromNode( listenNode ) );
		#end
	}
	
	public function throwMissingApplicationContextNameException( xml : Xml ) : Void
	{
		#if macro
		Context.error( "Fails to retrieve applicationContext name. You should add 'name' attribute to the root of your xml context", this._positionTracker.makePositionFromNode( xml  ) );
		#end
	}
	
	public function throwValueException( message : String, vo : AssemblerVO ) : Void 
	{
		#if macro
		Context.error( message, this._positionTracker.makePositionFromNode( this._getXML( vo )  ) );
		#end
	}
	
	public function register( assemblerVO : AssemblerVO, xml : Xml ) : AssemblerVO
	{
		this._map.set( assemblerVO, xml );
		return assemblerVO;
	}
	
	//
	public function throwTypeNotFoundException( type : String, xml : Xml ) : Void 
	{
		#if macro
		Context.error( "Parsing error with '" + xml.nodeName + "' node, '" + type + "' type not found.", this._positionTracker.makePositionFromAttribute( xml, ContextAttributeList.TYPE ) );
		#end
	}
	
	public function throwClassNotFoundException( type : String, xml : Xml ) : Void 
	{
		#if macro
		Context.error( "Parsing error with '" + xml.nodeName + "' node, '" + type + "' type not found.", this._positionTracker.makePositionFromAttribute( xml, ContextAttributeList.VALUE ) );
		#end
	}
	
	public function throwStaticRefNotFoundException( type : String, xml : Xml ) : Void 
	{
		#if macro
		Context.error( "Parsing error with '" + xml.nodeName + "' node, '" + type + "' type not found.", this._positionTracker.makePositionFromAttribute( xml, ContextAttributeList.STATIC_REF ) );
		#end
	}
	
	public function throwMappedTypeNotFoundException( type : String, xml : Xml ) : Void
	{
		#if macro
		Context.error( "Parsing error with '" + xml.nodeName + "' node, '" + type + "' type not found.", this._positionTracker.makePositionFromAttribute( xml, ContextAttributeList.MAP_TYPE ) );
		#end
	}
	
	public function throwCommandClassNotFoundException( type : String, xml : Xml ) : Void
	{
		#if macro
		Context.error( "Parsing error with '" + xml.nodeName + "' node, '" + type + "' type not found.", this._positionTracker.makePositionFromAttribute( xml, ContextAttributeList.COMMAND_CLASS ) );
		#end
	}
	
	public function throwStrategyNotFoundException( type : String, xml : Xml ) : Void
	{
		#if macro
		Context.error( "Parsing error with '" + xml.nodeName + "' node, '" + type + "' type not found.", this._positionTracker.makePositionFromAttribute( xml, ContextAttributeList.STRATEGY ) );
		#end
	}
	
	//
	private function _getXML( vo : AssemblerVO ) : Xml
	{
		return this._map.get( vo );
	}
}