package hex.compiler.parser.xml;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr.Position;

/**
 * ...
 * @author Francis Bourre
 */
class PositionTracker implements IPositionTracker
{
	public var nodeMap( default, never ) : Map<Xml, DSLPosition> = new Map<Xml, DSLPosition>();
	public var attributeMap( default, never ) : Map<Xml, Map<String, DSLPosition>> = new Map<Xml, Map<String, DSLPosition>>();
	
	public function new() 
	{
		
	}
	
	public function makePositionFromNode( xml : Xml ) : Position
	{
		var dslPosition = this.nodeMap.get( xml );
		return Context.makePosition( { min: dslPosition.from, max: dslPosition.to, file: dslPosition.file } );
	}
	
	public function makePositionFromAttribute( xml : Xml, attributeName : String ) : Position
	{
		var dslPosition = this.attributeMap.get( xml ).get( attributeName );
		return Context.makePosition( { min: dslPosition.from, max: dslPosition.to, file: dslPosition.file } );
	}
}
#end