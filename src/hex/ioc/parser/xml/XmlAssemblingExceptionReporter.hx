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
	var _positionTracker ( default, null ) : IPositionTracker;

	public function new( positionTracker : IPositionTracker ) 
	{
		this._positionTracker = positionTracker;
	}
	
	public function getPosition( xml : Xml, ?additionalInformations : Dynamic ) : Position
	{
		return additionalInformations == null ? this._positionTracker.makePositionFromNode( xml ) : this._positionTracker.makePositionFromAttribute( xml, additionalInformations );
	}
}
#end