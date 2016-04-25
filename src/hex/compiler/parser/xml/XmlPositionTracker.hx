package hex.compiler.parser.xml;

import com.tenderowls.xml176.Xml176Parser.Xml176Document;
import haxe.macro.Context;
import haxe.macro.Expr.Position;

/**
 * ...
 * @author Francis Bourre
 */
class XmlPositionTracker
{
	var _document 	: Xml176Document;
	var _data		: Array<XMLRawData>;
	
	public function new( document : Xml176Document, data : Array<XMLRawData> ) 
	{
		this._document 	= document;
		this._data		= data;
	}
	
	#if macro
	function _makePosition( pos : { from: Int, ?to: Int } ) : Position
	{
		var element = this._findEntry( pos );
		var posFrom = pos.from - element.absPosition + element.header;
		var posTo 	= pos.to - element.absPosition + element.header;
		
		var childOffset = 0;
		for ( child in element.children )
		{
			if ( child.absPosition < pos.from )
			{
				childOffset += child.absIncludeLength - child.absLength;
			}
		}
		
		return Context.makePosition( { min: posFrom + childOffset, max: posTo + childOffset, file: element.path } );
	}
	
	function _findEntry( pos ) : XMLRawData
	{
		var result : XMLRawData = null;
		
		for ( element in this._data )
		{
			if ( pos.from >= element.absPosition && pos.to < element.absPosition + element.absLength )
			{
				if ( result == null || element.absPosition > result.absPosition )
				{
					result = element;
				}
			}
		}

		return result;
	}
	
	public function makePositionFromNode( xml : Xml ) : Position
	{
		return this._makePosition( this._document.getNodePosition( xml ) );
	}
	
	public function makePositionFromAttribute( xml : Xml, attributeName : String ) : Position
	{
		return this._makePosition( this._document.getAttrPosition( xml, attributeName ) );
	}
	#end
}