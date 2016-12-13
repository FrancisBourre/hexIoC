package hex.compiler.parser.xml;
import hex.compiler.parser.DSLPosition;

#if (macro || doc_gen)

import haxe.macro.Expr.Position;
/**
 * @author Francis Bourre
 */
interface IPositionTracker 
{
	var nodeMap( default, never ) : Map<Xml, DSLPosition>;
	var attributeMap( default, never ) : Map<Xml, Map<String, DSLPosition>>;
	function makePositionFromNode( xml : Xml ) : Position;
	function makePositionFromAttribute( xml : Xml, attributeName : String ) : Position;
}
#end