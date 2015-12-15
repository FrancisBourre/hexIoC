package hex.ioc.parser.xml.mock;

import hex.structures.Point;

/**
 * ...
 * @author Francis Bourre
 */
class MockRectangle
{
	public var x 		: Float;
	public var y 		: Float;
	public var width 	: Float;
	public var height 	: Float;
	
	public function new( x : Float = 0, y : Float = 0, width : Float = 0, height : Float = 0 ) 
	{
		this.x 		= x;
		this.y 		= y;
		this.width 	= width;
		this.height = height;
	}
	
	public var size ( get, set ) : Point;
	function get_size() : Point
	{
		return new Point( this.width, this.height );
	}
	
	function set_size( size : Point ) : Point
	{
		this.width = size.x;
		this.height = size.y;

		return size;
	}
	
	public function reset() : Void
	{
		this.x 		= 0;
		this.y 		= 0;
		this.width 	= 0;
		this.height = 0;
	}
	
	public function offsetPoint( p : Point ) : Void
	{
		this.x += p.x;
		this.y += p.y;
	}
}