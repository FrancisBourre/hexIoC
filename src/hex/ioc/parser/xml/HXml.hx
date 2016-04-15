package hex.ioc.parser.xml;

@:enum abstract XmlType( Int ) 
{
	var Element 				= 0;
	var PCData 					= 1;
	var CData 					= 2;
	var Comment 				= 3;
	var DocType 				= 4;
	var ProcessingInstruction 	= 5;
	var Document 				= 6;
}

class HXml 
{
	static public var Element(default,null) 				= XmlType.Element;
	static public var PCData(default,null) 					= XmlType.PCData;
	static public var CData(default,null) 					= XmlType.CData;
	static public var Comment(default,null) 				= XmlType.Comment;
	static public var DocType(default,null) 				= XmlType.DocType;
	static public var ProcessingInstruction(default,null) 	= XmlType.ProcessingInstruction;
	static public var Document(default,null) 				= XmlType.Document;

	static public function parse( str : String ) : HXml 
	{
		return HXmlParser.parse( str );
	}
	
	public var line : UInt = 0;

	/**
		Returns the type of the Xml Node. This should be used before
		accessing other functions since some might raise an exception
		if the node type is not correct.
	**/
	public var nodeType( default, null ) : XmlType;

	/**
		Returns the node name of an Element.
	**/
	@:isVar public var nodeName( get, set ) : String;

	/**
		Returns the node value. Only works if the Xml node is not an Element or a Document.
	**/
	@:isVar public var nodeValue( get, set ) : String;

	/**
		Returns the parent object in the Xml hierarchy.
		The parent can be [null], an Element or a Document.
	**/
	public var parent( default, null ) : HXml;

	var children		: Array<HXml>;
	var attributeMap	: Map<String, String>;

	inline function get_nodeName() : String
	{
		if ( nodeType != Element ) 
		{
			throw 'Bad node type, expected Element but found $nodeType';
		}
		return nodeName;
	}

	inline function set_nodeName( v : String ) : String
	{
		if ( nodeType != Element ) 
		{
			throw 'Bad node type, expected Element but found $nodeType';
		}
		
		return this.nodeName = v;
	}

	inline function get_nodeValue() 
	{
		if ( nodeType == Document || nodeType == Element ) 
		{
			throw 'Bad node type, unexpected $nodeType';
		}
		return nodeValue;
	}

	inline function set_nodeValue( v ) 
	{
		if ( nodeType == Document || nodeType == Element ) 
		{
			throw 'Bad node type, unexpected $nodeType';
		}
		return this.nodeValue = v;
	}

	/**
		Creates a node of the given type.
	**/
	static public function createElement( name : String ) : HXml 
	{
		var xml = new HXml( Element );
		xml.nodeName = name;
		return xml;
	}

	/**
		Creates a node of the given type.
	**/
	static public function createPCData( data : String ) : HXml 
	{
		var xml = new HXml( PCData );
		xml.nodeValue = data;
		return xml;
	}

	/**
		Creates a node of the given type.
	**/
	static public function createCData( data : String ) : HXml 
	{
		var xml = new HXml( CData );
		xml.nodeValue = data;
		return xml;
	}

	/**
		Creates a node of the given type.
	**/
	static public function createComment( data : String ) : HXml 
	{
		var xml = new HXml( Comment );
		xml.nodeValue = data;
		return xml;
	}

	/**
		Creates a node of the given type.
	**/
	static public function createDocType( data : String ) : HXml 
	{
		var xml = new HXml( DocType );
		xml.nodeValue = data;
		return xml;
	}

	/**
		Creates a node of the given type.
	**/
	static public function createProcessingInstruction( data : String ) : HXml 
	{
		var xml = new HXml( ProcessingInstruction );
		xml.nodeValue = data;
		return xml;
	}

	/**
		Creates a node of the given type.
	**/
	static public function createDocument() : HXml 
	{
		return new HXml( Document );
	}

	/**
		Get the given attribute of an Element node. Returns [null] if not found.
		Attributes are case-sensitive.
	**/
	public function get( att : String ) : String 
	{
		if ( nodeType != Element ) 
		{
			throw 'Bad node type, expected Element but found $nodeType';
		}
		return attributeMap[ att ];
	}

	/**
		Set the given attribute value for an Element node.
		Attributes are case-sensitive.
	**/
	public function set( att : String, value : String ) : Void 
	{
		if ( nodeType != Element ) 
		{
			throw 'Bad node type, expected Element but found $nodeType';
		}
		attributeMap.set( att, value );
	}

	/**
		Removes an attribute for an Element node.
		Attributes are case-sensitive.
	**/
	public function remove( att : String ) : Void 
	{
		if ( nodeType != Element ) 
		{
			throw 'Bad node type, expected Element but found $nodeType';
		}
		attributeMap.remove( att );
	}

	/**
		Tells if the Element node has a given attribute.
		Attributes are case-sensitive.
	**/
	public function exists( att : String ) : Bool 
	{
		if ( nodeType != Element ) 
		{
			throw 'Bad node type, expected Element but found $nodeType';
		}
		return attributeMap.exists( att );
	}

	/**
		Returns an [Iterator] on all the attribute names.
	**/
	public function attributes() : Iterator<String> 
	{
		if ( nodeType != Element ) 
		{
			throw 'Bad node type, expected Element but found $nodeType';
		}
		return attributeMap.keys();
	}

	/**
		Returns an iterator of all child nodes.
		Only works if the current node is an Element or a Document.
	**/
	public inline function iterator() : Iterator<HXml> 
	{
		ensureElementType();
		return children.iterator();
	}

	/**
		Returns an iterator of all child nodes which are Elements.
		Only works if the current node is an Element or a Document.
	**/
	public function elements() : Iterator<HXml> 
	{
		ensureElementType();
		var ret = [ for ( child in children ) if ( child.nodeType == Element ) child ];
		return ret.iterator();
	}

	/**
		Returns an iterator of all child nodes which are Elements with the given nodeName.
		Only works if the current node is an Element or a Document.
	**/
	public function elementsNamed( name : String ) : Iterator<HXml> 
	{
		ensureElementType();
		var ret = [ for ( child in children ) if ( child.nodeType == Element && child.nodeName == name ) child ];
		return ret.iterator();
	}

	/**
		Returns the first child node.
	**/
	public inline function firstChild() : HXml 
	{
		ensureElementType();
		return children[ 0 ];
	}

	/**
		Returns the first child node which is an Element.
	**/
	public function firstElement() : HXml 
	{
		ensureElementType();
		
		for ( child in children ) 
		{
			if (child.nodeType == Element) 
			{
				return child;
			}
		}
		
		return null;
	}

	/**
		Adds a child node to the Document or Element.
		A child node can only be inside one given parent node, which is indicated by the [parent] property.
		If the child is already inside this Document or Element, it will be moved to the last position among the Document or Element's children.
		If the child node was previously inside a different node, it will be moved to this Document or Element.
	**/
	public function addChild( x : HXml ) : Void 
	{
		ensureElementType();
		
		if (x.parent != null) 
		{
			x.parent.removeChild(x);
		}
		
		children.push( x );
		x.parent = this;
	}

	/**
		Removes a child from the Document or Element.
		Returns true if the child was successfuly removed.
	**/
	public function removeChild( x : HXml ) : Bool 
	{
		ensureElementType();
		
		if ( children.remove( x ) ) 
		{
			x.parent = null;
			return true;
		}
		
		return false;
	}

	/**
		Inserts a child at the given position among the other childs.
		A child node can only be inside one given parent node, which is indicated by the [parent] property.
		If the child is already inside this Document or Element, it will be moved to the new position among the Document or Element's children.
		If the child node was previously inside a different node, it will be moved to this Document or Element.
	**/
	public function insertChild( x : HXml, pos : Int ) : Void 
	{
		ensureElementType();
		
		if ( x.parent != null ) 
		{
			x.parent.children.remove( x );
		}
		
		children.insert( pos, x );
		x.parent = this;
	}

	/**
		Returns a String representation of the Xml node.
	**/
	public inline function toString() : String 
	{
		return HXMLPrinter.print( this );
	}

	function new(nodeType:XmlType) {
		this.nodeType = nodeType;
		children = [];
		attributeMap = new Map();
	}

	inline function ensureElementType() 
	{
		if (nodeType != Document && nodeType != Element) 
		{
			throw 'Bad node type, expected Element or Document but found $nodeType';
		}
	}
}
