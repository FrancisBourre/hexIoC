#if macro
package hex.compiler.parser.xml;

import haxe.macro.Expr.Position;
/**
 * @author Francis Bourre
 */

interface IXmlPositionTracker 
{
	function makePositionFromNode( xml : Xml ) : Position;
	function makePositionFromAttribute( xml : Xml, attributeName : String ) : Position;
}
#end