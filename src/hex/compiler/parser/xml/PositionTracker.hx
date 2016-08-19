#if macro
package hex.compiler.parser.xml;

import com.tenderowls.xml176.Xml176Parser.Xml176Parser;
import haxe.macro.Context;
import haxe.macro.Expr.Position;

/**
 * ...
 * @author Francis Bourre
 */
class PositionTracker implements IXmlPositionTracker
{
	public function new() 
	{

	}
	
	public function makePositionFromNode( xml : Xml ) : Position
	{
		var dslPosition = Xml176Parser.nodeMap.get( xml );
		return Context.makePosition( { min: dslPosition.from, max: dslPosition.to, file: dslPosition.file } );
	}
	
	public function makePositionFromAttribute( xml : Xml, attributeName : String ) : Position
	{
		var dslPosition = Xml176Parser.attrMap.get( xml ).get( attributeName );
		return Context.makePosition( { min: dslPosition.from, max: dslPosition.to, file: dslPosition.file } );
	}
}
#end